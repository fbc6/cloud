<?php
/**
 * ownCloud
 *
 * @author Artur Neumann <info@jankaritech.com>
 * @copyright Copyright (c) 2018 Artur Neumann info@jankaritech.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU AFFERO GENERAL PUBLIC LICENSE for more details.
 *
 * You should have received a copy of the GNU Affero General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use PHPUnit\Framework\Assert;
use TestHelpers\HttpRequestHelper;
use TestHelpers\SetupHelper;

require_once 'bootstrap.php';

/**
 * Context for encryption specific steps
 */
class EncryptionContext implements Context {

	/**
	 * @var FeatureContext
	 */
	private $featureContext;

	/**
	 * @var OccContext
	 */
	private $occContext;

	/**
	 * @return void
	 * @throws Exception
	 */
	public function recreateMasterKeyUsingOccCommand() {
		$this->featureContext->runOcc(['encryption:recreate-master-key', '-y']);
	}

	/**
	 * @When the administrator successfully recreates the encryption masterkey using the occ command
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function adminRecreatesMasterKeyUsingOccCommand() {
		$this->recreateMasterKeyUsingOccCommand();
	}

	/**
	 * @Given the administrator has successfully recreated the encryption masterkey
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function adminHasRecreatedMasterKeyUsingOccCommand() {
		$this->recreateMasterKeyUsingOccCommand();
		$this->occContext->theCommandShouldHaveBeenSuccessful();
	}

	/**
	 * @Given encryption has been enabled
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function encryptionHasBeenEnabled() {
		$this->featureContext->runOcc(['encryption:enable']);
		$this->occContext->theCommandShouldHaveBeenSuccessful();
	}

	/**
	 * @param $encryptionType
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function setEncryptionTypeUsingTheOccCommand($encryptionType) {
		$this->featureContext->runOcc(
			["encryption:select-encryption-type", $encryptionType, "-y"]
		);
	}

	/**
	 * @When the administrator sets the encryption type to :encryptionType using the occ command
	 *
	 * @param string $encryptionType
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function theAdministratorSetsEncryptionTypeToUsingTheOccCommand($encryptionType) {
		$this->setEncryptionTypeUsingTheOccCommand($encryptionType);
	}

	/**
	 * @Given the administrator has set the encryption type to :encryptionType
	 *
	 * @param string $encryptionType
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function theAdministratorHasSetEncryptionTypeToUsingTheOccCommand($encryptionType) {
		$this->setEncryptionTypeUsingTheOccCommand($encryptionType);
		$this->occContext->theCommandShouldHaveBeenSuccessful();
	}

	/**
	 * @return void
	 * @throws Exception
	 */
	public function encryptAllDataUsingTheOccCommand() {
		$this->featureContext->runOcc(["encryption:encrypt-all", "-y"]);
	}

	/**
	 * @When the administrator encrypts all data using the occ command
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function theAdministratorEncryptsAllDataUsingTheOccCommand() {
		$this->encryptAllDataUsingTheOccCommand();
	}

	/**
	 * @Given the administrator has encrypted all the data
	 *
	 * @return void
	 * @throws \Exception
	 */
	public function theAdministratorHasEncryptedAllDataUsingTheOccCommand() {
		$this->encryptAllDataUsingTheOccCommand();
		$this->occContext->theCommandShouldHaveBeenSuccessful();
	}

	/**
	 * @When the administrator decrypts user keys based encryption with recovery key :recoveryKey using the occ command
	 *
	 * @param string $recoveryKey
	 *
	 * @return void
	 */
	public function theAdministratorDecryptsUserKeysBasedEncryptionWithKey($recoveryKey) {
		$this->occContext->invokingTheCommandWithEnvVariable(
			"encryption:decrypt-all -m recovery -c yes",
			'OC_RECOVERY_PASSWORD',
			$recoveryKey
		);
	}

	/**
	 * @Then file :fileName of user :username should not be encrypted
	 *
	 * @param string $fileName
	 * @param string $username
	 *
	 * @return void
	 */
	public function fileOfUserShouldNotBeEncrypted($fileName, $username) {
		$fileName = \ltrim($fileName, "/");
		$filePath = "data/$username/files/$fileName";
		$this->featureContext->readFileInServerRoot($filePath);

		$response = $this->featureContext->getResponse();
		$parsedResponse = HttpRequestHelper::getResponseXml($response);
		$encodedFileContent = (string) $parsedResponse->data->element->contentUrlEncoded;
		$fileContent = \urldecode($encodedFileContent);

		$this->featureContext->userDownloadsFileUsingTheAPI($username, "/$fileName");
		$fileContentServer = (string) $this->featureContext->getResponse()->getBody();

		Assert::assertEquals(
			$fileContentServer,
			$fileContent,
			"The content of file {$fileName} is {$fileContent}, but was supposed to be non-encrypted: {$fileContentServer}"
		);
	}

	/**
	 * @Then file :fileName of user :username should be encrypted
	 *
	 * @param string $fileName
	 * @param string $username
	 *
	 * @return void
	 */
	public function fileOfUserShouldBeEncrypted($fileName, $username) {
		$fileName = \ltrim($fileName, "/");
		$filePath = "data/$username/files/$fileName";
		$this->featureContext->readFileInServerRoot($filePath);

		$response = $this->featureContext->getResponse();
		$parsedResponse = HttpRequestHelper::getResponseXml($this->featureContext->getResponse());
		$encodedFileContent = (string) $parsedResponse->data->element->contentUrlEncoded;
		$fileContent = \urldecode($encodedFileContent);
		$expectedContentStart = "HBEGIN:oc_encryption_module:OC_DEFAULT_MODULE:cipher:AES-256-CTR:signed:true";

		Assert::assertStringStartsWith(
			$expectedContentStart,
			$fileContent,
			"FileContent: {$fileContent} of file {$fileName} is expected to start with encrypted string {$expectedContentStart}, but does not"
		);
	}

	/**
	 * @BeforeScenario
	 *
	 * @param BeforeScenarioScope $scope
	 *
	 * @return void
	 */
	public function setUpScenario(BeforeScenarioScope $scope) {
		// Get the environment
		$environment = $scope->getEnvironment();
		// Get all the contexts you need in this context
		$this->featureContext = $environment->getContext('FeatureContext');
		$this->occContext = $environment->getContext('OccContext');
		SetupHelper::init(
			$this->featureContext->getAdminUsername(),
			$this->featureContext->getAdminPassword(),
			$this->featureContext->getBaseUrl(),
			$this->featureContext->getOcPath()
		);
	}
}

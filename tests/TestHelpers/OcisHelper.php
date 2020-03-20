<?php
/**
 * ownCloud
 *
 * @author    Artur Neumann <artur@jankaritech.com>
 * @copyright Copyright (c) 2020 Artur Neumann artur@jankaritech.com
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License,
 * as published by the Free Software Foundation;
 * either version 3 of the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 *
 */

namespace TestHelpers;

/**
 * Class OcisHelper
 *
 * Helper functions that are needed to run tests on OCIS
 *
 * @package TestHelpers
 */
class OcisHelper {

	/**
	 * @return bool
	 */
	public static function isTestingOnOcis() {
		return (\getenv("TEST_OCIS") === "true");
	}

	/**
	 * @param string $user
	 *
	 * @return void
	 */
	public static function deleteRevaUserData($user = "") {
		self::recurseRmdir(self::getOcisRevaDataRoot() . "/data/" . $user);
	}

	/**
	 * @return int|string
	 */
	public static function getLdapPort() {
		$port = \getenv("REVA_LDAP_PORT");
		return $port ? $port : 636;
	}

	/**
	 * @return bool
	 */
	public static function useSsl() {
		return (self::getLdapPort() === 636);
	}

	/**
	 * @return string
	 */
	public static function getBaseDN() {
		$port = \getenv("REVA_LDAP_BASE_DN");
		return $port ? $port : "dc=owncloud,dc=com";
	}

	/**
	 * @return string
	 */
	public static function getHostname() {
		$port = \getenv("REVA_LDAP_HOSTNAME");
		return $port ? $port : "localhost";
	}

	/**
	 * @return string
	 */
	public static function getBindDN() {
		$port = \getenv("REVA_LDAP_BIND_DN");
		return $port ? $port : "cn=admin,dc=owncloud,dc=com";
	}

	/**
	 * @return string
	 */
	private static function getOcisRevaDataRoot() {
		$root = \getenv("OCIS_REVA_DATA_ROOT");
		if (($root === false || $root === "") && self::isTestingOnOcis()) {
			$root = "/var/tmp/reva/";
		}
		return $root;
	}

	/**
	 * @param string $dir
	 *
	 * @return bool
	 */
	private static function recurseRmdir($dir) {
		if (\file_exists($dir) === true) {
			$files = \array_diff(\scandir($dir), ['.', '..']);
			foreach ($files as $file) {
				if (\is_dir("$dir/$file")) {
					self::recurseRmdir("$dir/$file");
				} else {
					\unlink("$dir/$file");
				}
			}
			return \rmdir($dir);
		}
		return true;
	}
}

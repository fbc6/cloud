@webUI @federation-app-required @insulated @disablePreviews @TestAlsoOnExternalUserBackend @files_sharing-app-required
Feature: Federation Sharing - sharing with users on other cloud storages
  As a user
  I want to share files with any users on other cloud storages
  So that other users have access to these files

  Background:
    Given using server "REMOTE"
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "simple-folder"
    And user "user1" has created folder "simple-empty-folder"
    And user "user1" has uploaded file with content "I am lorem.txt inside simple-folder" to "/simple-folder/lorem.txt"
    And user "user1" has uploaded file "filesForUpload/lorem.txt" to "/lorem.txt"
    And using server "LOCAL"
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "simple-folder"
    And user "user1" has created folder "simple-empty-folder"
    And user "user1" has uploaded file with content "I am lorem.txt inside simple-folder" to "/simple-folder/lorem.txt"
    And user "user1" has uploaded file "filesForUpload/lorem.txt" to "/lorem.txt"
    And user "user1" has logged in using the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "no"


  Scenario: declining a federation share on the webUI
    Given user "user1" from server "REMOTE" has shared "/lorem.txt" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user declines the offered remote shares using the webUI
    Then file "lorem (2).txt" should not be listed on the webUI
    And file "lorem (2).txt" should not be listed in the shared-with-you page on the webUI

  Scenario: automatically accept a federation share when it is allowed by the config
    Given parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    When user "user1" from server "REMOTE" shares "/lorem.txt" with user "user1" from server "LOCAL" using the sharing API
    And the user has reloaded the current page of the webUI
    Then file "lorem (2).txt" should be listed on the webUI

  Scenario: User-based auto accepting is disabled while global is enabled
    Given parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    When the user disables automatically accepting remote shares from trusted servers
    And user "user1" from server "REMOTE" shares "/lorem.txt" with user "user1" from server "LOCAL" using the sharing API
    Then user "user1" should not see the following elements
      | /lorem%20(2).txt |

  Scenario: one user disabling user-based auto accepting while global is enabled has no effect on other users
    Given user "user2" has been created with default attributes and without skeleton files
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "/lorem.txt"
    And parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    When the user disables automatically accepting remote shares from trusted servers
    And user "user1" from server "REMOTE" shares "/lorem.txt" with user "user2" from server "LOCAL" using the sharing API
    Then user "user2" should see the following elements
      | /lorem%20(2).txt |

  Scenario: User-based accepting from trusted server checkbox is not visible while global is disabled
    Given parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "no"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    Then User-based auto accepting from trusted servers checkbox should not be displayed on the personal sharing settings page on the webUI

  @skip @issue-34742
  Scenario: User-based & global auto accepting is enabled but remote server is not trusted
    Given parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    When the user disables automatically accepting remote shares from trusted servers
    And the user enables automatically accepting remote shares from trusted servers
    And user "user1" from server "REMOTE" shares "/lorem.txt" with user "user1" from server "LOCAL" using the sharing API
    Then user "user1" should not see the following elements
      | /lorem%20(2).txt |
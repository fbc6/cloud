@api @TestAlsoOnExternalUserBackend @skipOnOcis @issue-ocis-reva-18
Feature: users cannot upload a file to a blacklisted name using old chunking
  As an administrator
  I want to be able to prevent users from uploading files to specified file names
  So that I can prevent unwanted file names existing in the cloud storage

  Background:
    Given using OCS API version "1"
    And using old DAV path
    And user "user0" has been created with default attributes and skeleton files

  @issue-36645
  Scenario: Upload a file to a filename that is banned by default using old chunking
    When user "user0" uploads file "filesForUpload/textfile.txt" to "/.htaccess" in 3 chunks using the WebDAV API
    Then the HTTP status code should be "507"
    #Then the HTTP status code should be "403"
    And as "user0" file ".htaccess" should not exist

  @issue-36645
  Scenario: Upload a file to a banned filename using old chunking
    When the administrator updates system config key "blacklisted_files" with value '["blacklisted-file.txt",".htaccess"]' and type "json" using the occ command
    And user "user0" uploads file "filesForUpload/textfile.txt" to "blacklisted-file.txt" in 3 chunks using the WebDAV API
    Then the HTTP status code should be "507"
    #Then the HTTP status code should be "403"
    And as "user0" file "blacklisted-file.txt" should not exist

  @skipOnOcV10.3 @issue-36645
  Scenario Outline: upload a file to a filename that matches blacklisted_files_regex using old chunking
    # Note: we have to write JSON for the value, and to get a backslash in the double-quotes we have to escape it
    # The actual regular expressions end up being .*\.ext$ and ^bannedfilename\..+
    Given the administrator has updated system config key "blacklisted_files_regex" with value '[".*\\.ext$","^bannedfilename\\..+","containsbannedstring"]' and type "json"
    When user "user0" uploads file "filesForUpload/textfile.txt" to "<filename>" in 3 chunks using the WebDAV API
    Then the HTTP status code should be "<http-status>"
    And as "user0" file "<filename>" should not exist
    Examples:
      | filename                      | http-status | comment     |
      | filename.ext                  | 507         | issue-36645 |
      | bannedfilename.txt            | 403         | ok          |
      | this-ContainsBannedString.txt | 403         | ok          |

  @skipOnOcV10.3
  Scenario: upload a file to a filename that does not match blacklisted_files_regex using old chunking
    # Note: we have to write JSON for the value, and to get a backslash in the double-quotes we have to escape it
    # The actual regular expressions end up being .*\.ext$ and ^bannedfilename\..+
    Given the administrator has updated system config key "blacklisted_files_regex" with value '[".*\\.ext$","^bannedfilename\\..+","containsbannedstring"]' and type "json"
    When user "user0" uploads file "filesForUpload/textfile.txt" to "not-contains-banned-string.txt" in 3 chunks using the WebDAV API
    Then the HTTP status code should be "201"
    And as "user0" file "not-contains-banned-string.txt" should exist

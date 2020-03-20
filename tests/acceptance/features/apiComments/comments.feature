@api @TestAlsoOnExternalUserBackend @comments-app-required @skipOnOcis @issue-ocis-reva-13
Feature: Comments

  Background:
    Given using new DAV path
    And user "user0" has been created with default attributes and skeleton files

  @smokeTest
  Scenario: Getting info of comments using files endpoint
    Given as user "user0"
    And the user has uploaded file "filesForUpload/textfile.txt" to "/myFileToComment.txt"
    And the user has commented with content "My first comment" on file "/myFileToComment.txt"
    And the user should have the following comments on file "/myFileToComment.txt"
      | user  | comment          |
      | user0 | My first comment |
    When the user gets the following properties of folder "/myFileToComment.txt" using the WebDAV API
      | propertyName       |
      | oc:comments-href   |
      | oc:comments-count  |
      | oc:comments-unread |
    Then the single response should contain a property "oc:comments-count" with value "1"
    And the single response should contain a property "oc:comments-unread" with value "0"
    And the single response should contain a property "oc:comments-href" with value "%a_comment_url%"

  Scenario: Getting more info about comments using REPORT method
    Given as user "user0"
    And the user has uploaded file "filesForUpload/textfile.txt" to "myFileToComment.txt"
    And the user has commented with content "My first comment" on file "myFileToComment.txt"
    When the user gets all information about the comments on file "myFileToComment.txt" using the WebDAV REPORT API
    Then the following comment properties should be listed
      | propertyName     | propertyValue    |
      | verb             | comment          |
      | actorType        | users            |
      | actorId          | user0            |
      | objectType       | files            |
      | isUnread         | false            |
      | actorDisplayName | User Zero        |
      | message          | My first comment |

  Scenario: Getting more info about comments using PROPFIND method
    Given as user "user0"
    And the user has uploaded file "filesForUpload/textfile.txt" to "myFileToComment.txt"
    And the user has commented with content "My first comment" on file "myFileToComment.txt"
    When the user gets the following comment properties of file "myFileToComment.txt" using the WebDAV PROPFIND API
      | propertyName        |
      | oc:verb             |
      | oc:actorType        |
      | oc:actorId          |
      | oc:objectType       |
      | oc:isUnread         |
      | oc:actorDisplayName |
      | oc:message          |
    Then the HTTP status code should be success
    And the following comment properties should be listed
      | propertyName     | propertyValue    |
      | verb             | comment          |
      | actorType        | users            |
      | actorId          | user0            |
      | objectType       | files            |
      | isUnread         | false            |
      | actorDisplayName | User Zero        |
      | message          | My first comment |

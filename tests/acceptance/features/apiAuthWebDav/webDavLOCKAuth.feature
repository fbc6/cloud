@api @TestAlsoOnExternalUserBackend
Feature: LOCK file/folder

  Background:
    Given user "user0" has been created with default attributes and without skeleton files
    And user "user0" has uploaded file with content "some data" to "/textfile0.txt"
    And user "user0" has uploaded file with content "some data" to "/textfile1.txt"
    And user "user0" has created folder "/PARENT"
    And user "user0" has created folder "/FOLDER"
    And user "user0" has uploaded file with content "some data" to "/PARENT/parent.txt"
    And user "user1" has been created with default attributes and without skeleton files

  @smokeTest
  Scenario: send LOCK requests to webDav endpoints as normal user with wrong password
    When user "user0" requests these endpoints with "LOCK" including body using password "invalid" then the status codes should be as listed
      | endpoint                                      | http-code | body          |
      | /remote.php/webdav/textfile0.txt              | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/textfile0.txt     | 401       | doesnotmatter |
      | /remote.php/webdav/PARENT                     | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT            | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 401       | doesnotmatter |

  @smokeTest
  Scenario: send LOCK requests to webDav endpoints as normal user with no password
    When user "user0" requests these endpoints with "LOCK" including body using password "" then the status codes should be as listed
      | endpoint                                      | http-code | body          |
      | /remote.php/webdav/textfile0.txt              | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/textfile0.txt     | 401       | doesnotmatter |
      | /remote.php/webdav/PARENT                     | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT            | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 401       | doesnotmatter |

  @skipOnOcis @issue-ocis-reva-9
  Scenario: send LOCK requests to another user's webDav endpoints as normal user
    When user "user1" requests these endpoints with "LOCK" including body then the status codes should be as listed
      | endpoint                                      | http-code | body                                                                                                                  |
      | /remote.php/dav/files/user0/textfile0.txt     | 403       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/PARENT            | 403       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 404       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |

  @skipOnOcV10 @issue-ocis-reva-9
  #after fixing all issues delete this Scenario and use the one above
  Scenario: send LOCK requests to another user's webDav endpoints as normal user
    When user "user1" requests these endpoints with "LOCK" including body then the status codes should be as listed
      | endpoint                                      | http-code | body                                                                                                                  |
      | /remote.php/dav/files/user0/textfile0.txt     | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/PARENT            | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |

  Scenario: send LOCK requests to webDav endpoints using invalid username but correct password
    When user "usero" requests these endpoints with "LOCK" including body using the password of user "user0" then the status codes should be as listed
      | endpoint                                      | http-code | body          |
      | /remote.php/webdav/textfile0.txt              | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/textfile0.txt     | 401       | doesnotmatter |
      | /remote.php/webdav/PARENT                     | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT            | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 401       | doesnotmatter |

  Scenario: send LOCK requests to webDav endpoints using valid password and username of different user
    When user "user1" requests these endpoints with "LOCK" including body using the password of user "user0" then the status codes should be as listed
      | endpoint                                      | http-code | body          |
      | /remote.php/webdav/textfile0.txt              | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/textfile0.txt     | 401       | doesnotmatter |
      | /remote.php/webdav/PARENT                     | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT            | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 401       | doesnotmatter |

  @smokeTest
  Scenario: send LOCK requests to webDav endpoints without any authentication
    When a user requests these endpoints with "LOCK" and no authentication then the status codes should be as listed
      | endpoint                                      | http-code | body          |
      | /remote.php/webdav/textfile0.txt              | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/textfile0.txt     | 401       | doesnotmatter |
      | /remote.php/webdav/PARENT                     | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT            | 401       | doesnotmatter |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 401       | doesnotmatter |

  @skipOnOcis @issue-ocis-reva-37
  Scenario: send LOCK requests to webDav endpoints using token authentication should not work
    Given token auth has been enforced
    And a new browser session for "user0" has been started
    And the user has generated a new app password named "my-client"
    When the user requests these endpoints with "LOCK" using the generated app password then the status codes should be as listed
      | endpoint                                      | http-code |
      | /remote.php/webdav/textfile0.txt              | 401       |
      | /remote.php/dav/files/user0/textfile0.txt     | 401       |
      | /remote.php/webdav/PARENT                     | 401       |
      | /remote.php/dav/files/user0/PARENT            | 401       |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 401       |

  @skipOnOcis @issue-ocis-reva-37
  Scenario: send LOCK requests to webDav endpoints using app password token as password
    Given token auth has been enforced
    And a new browser session for "user0" has been started
    And the user has generated a new app password named "my-client"
    When the user "user0" requests these endpoints with "LOCK" using the basic auth and generated app password then the status codes should be as listed
      | endpoint                                      | http-code | body                                                                                                                  |
      | /remote.php/webdav/textfile0.txt              | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/textfile1.txt     | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/PARENT/parent.txt | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/webdav/PARENT                     | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |
      | /remote.php/dav/files/user0/FOLDER            | 200       | <?xml version='1.0' encoding='UTF-8'?><d:lockinfo xmlns:d='DAV:'> <d:lockscope><d:shared/></d:lockscope></d:lockinfo> |

@cli @skipOnLDAP @local_storage
Feature: export created local storage mounts from the command line
  As an admin
  I want to export all created local storage mounts from the command line
  So that I can view available local storage mounts

  Background:
    Given the administrator has created the local storage mount "local_storage2"
    And the administrator has created the local storage mount "new_local_storage"
    And the administrator has uploaded file with content "this is a file in local storage" to "/local_storage2/file-in-local-storage.txt"
    And the administrator has uploaded file with content "new file" to "/new_local_storage/new-file"

  Scenario: export the created mounts
    When the administrator exports the local storage mounts using the occ command
    Then the following local storage should be listed:
      | MountPoint         | Storage | AuthenticationType | Configuration | Options              | ApplicableUsers | ApplicableGroups |
      | /local_storage2    | Local   | None               | datadir:      |                      | All             |                  |
      | /new_local_storage | Local   | None               | datadir:      |                      | All             |                  |
      | /local_storage     | Local   | None               | datadir:      | enable_sharing: true | All             |                  |

  @issue-37054
  Scenario: export the created mounts when the system language is "de"
    Given the administrator has set the system language to "de"
    When the administrator exports the local storage mounts using the occ command
    Then the following local storage should be listed:
      | MountPoint         | Storage | AuthenticationType | Configuration | Options              | ApplicableUsers | ApplicableGroups |
      | /local_storage2    | Lokal   | Keine              | datadir:      |                      | All             |                  |
      | /new_local_storage | Lokal   | Keine              | datadir:      |                      | All             |                  |
      | /local_storage     | Lokal   | Keine              | datadir:      | enable_sharing: true | All             |                  |
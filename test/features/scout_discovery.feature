Feature: Vault Scout Discovery
  As a Power User
  I want the Vault Scout to recursively scan my local directories
  So that I can see a complete tree of my encrypted environments.

  Background:
    Given the App is initialized with a "Pro Max" theme
    And I am authenticated with a valid Master Key

  Scenario: Deep recursive scanning of a nested vault
    Given I have a local vault at "/Users/aldo/Vaults/Demo"
    And the vault contains 3 levels of nested directories
    When I trigger a "Scout Sync" from the Workbench
    Then the Scout should discover exactly 12 nodes
    And the Discovery Console should show "SCAN_COMPLETED" with 0 errors
    And I should see the tree populated in the Scout Sidepanel

  Scenario: Prevent path traversal during discovery
    Given I have a local vault at "/Users/aldo/Vaults/Security"
    When I attempt to scan a path with "../" segments
    Then the Scout should block the request with a "SecurityFailure"
    And the Discovery Console should log an "UNAUTHORIZED_PATH_TRAVERSAL" warning

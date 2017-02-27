@dfs_edu @dfs_fin @dfs_obio @dfs_obio_showroom @workflow @api
Feature: Workflow moderation states
  As a site administator, I need to be able to manage moderation states for
  content.

  Scenario: Anonymous users should not be able to access content in an unpublished, non-draft state.
    Given page content:
      | title             | path   | moderation_state |
      | Moderation Test 1 | /moderation-test-1 | needs_review     |
    When I go to "/moderation-test-1"
    Then the response status code should be 403

  Scenario: Users with permission to transition content between moderation states should be able to see content in an unpublished, non-draft state.
    Given I am logged in as a user with the "view any unpublished content" permission
    And page content:
      | title             | path   | moderation_state |
      | Moderation Test 2 | /moderation-test-2 | needs_review     |
    When I visit "/moderation-test-2"
    Then the response status code should be 200

  Scenario: Publishing an entity by transitioning it to a published state
    Given I am logged in as a user with the "view any unpublished content,use draft_needs_review transition,use needs_review_published transition,create page content,edit any page content,create url aliases,access toolbar,use moderation sidebar" permissions
    And page content:
      | title             | path   | moderation_state |
      | Moderation Test 3 | /moderation-test-3 | needs_review     |
    And I visit "/moderation-test-3"
    And I click "Tasks"
    And I click "Edit draft"
    And I select "Published" from "Moderation state"
    And I press "Save"
    And I visit "/user/logout"
    And I visit "/moderation-test-3"
    Then the response status code should be 200

  Scenario: Transitioning published content to an unpublished state
    Given I am logged in as a user with the "use draft_published transition,use published_archived transition,create page content,edit any page content,create url aliases,access toolbar,use moderation sidebar" permissions
    And page content:
      | title             | path   | moderation_state |
      | Moderation Test 4 | /moderation-test-4 | published        |
    And I visit "/moderation-test-4"
    And I click "Tasks"
    And I press the "Archive" button
    And I visit "/user/logout"
    And I go to "/moderation-test-4"
    Then the response status code should be 403

  Scenario: Filtering content by moderation state
    Given I am logged in as a user with the "access content overview" permission
    And page content:
      | title          | moderation_state |
      | John Cleese    | needs_review     |
      | Terry Gilliam  | needs_review     |
      | Michael Palin  | published        |
      | Graham Chapman | published        |
      | Terry Jones    | draft            |
      | Eric Idle      | needs_review     |
    When I visit "/admin/content/review"
    Then I should see "John Cleese"
    And I should see "Terry Gilliam"
    And I should not see "Michael Palin"
    And I should not see "Graham Chapman"
    And I should not see "Terry Jones"
    And I should see "Eric Idle"
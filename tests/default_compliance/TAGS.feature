Feature: TAGS related general feature

  Scenario Outline: Ensure that specific tags are defined
    Given I have resource that supports tags_all defined
    When it has tags_all
    Then it must contain tags_all
    Then it must contain "<tags>"
    And its value must match the "<value>" regex

    Examples:
    | tags           | value                   |
    | product        | JetbrainsSpace         |
    | cloud_platform | AmazonWebServices       |

  Scenario: Ensure that all resources have tags
    Given I have resource that supports tags defined
    Then it must contain tags
    And its value must not be null

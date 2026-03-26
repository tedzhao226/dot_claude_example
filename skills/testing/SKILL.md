---
name: testing
description: Guide for writing effective tests using Khorikov's principles and BDD. Use when writing tests, deciding what to test, choosing test strategy, or verifying AI-generated code. Triggers include "testing", "unit test", "write tests", "test strategy", "what to test", "mock", "test coverage", "bdd", "behavior driven", "given when then".
---

# Testing Principles

Based on Vladimir Khorikov's "Unit Testing Principles, Practices, and Patterns" + BDD for behavior-first testing at service boundaries.

For core rules (Four Pillars, Code Classification, Mocking, Glue Tests), see AGENTS.md Testing section.

## Observable Behavior vs Implementation

**Observable behavior:** Operations or state that help clients achieve their goals.

**Implementation details:** Everything else.

```python
# BAD - testing implementation
def test_user_creation():
    user = User("alice")
    assert user._internal_id is not None  # Implementation detail
    assert user._validation_ran == True   # Implementation detail

# GOOD - testing behavior
def test_user_creation():
    user = User("alice")
    assert user.name == "alice"           # Observable state
    assert user.is_valid()                # Observable behavior
```

**Rule:** Tests should turn red only when behavior changes, not when you refactor.

## BDD: Behavior as Specification

BDD extends "test behavior, not implementation" into a delivery model:

| Approach | Delivers | Tests Prove |
|----------|----------|-------------|
| **TDD** | Code | Code is correct |
| **BDD** | Behavior proof | Requirements are met |

BDD is not just E2E or integration testing. Any test written from the behavior perspective is BDD. The shift: describe **what the system does at its boundaries**, not how it's wired.

### Given/When/Then at Service Boundaries

Use GWT to describe behavior at domain and service boundaries:

```python
# Service boundary: order processing
def test_given_items_in_cart_when_checkout_then_creates_order():
    # Given - a cart with items
    cart = Cart(user_id="user-1")
    cart.add(Product("Widget", price=50), quantity=2)

    # When - checkout is requested
    order = order_service.checkout(cart)

    # Then - order reflects the cart
    assert order.status == OrderStatus.CREATED
    assert order.total == 100
    assert len(order.items) == 2

# Domain boundary: rate limiting
def test_given_premium_user_when_exceeding_base_quota_then_allows_burst():
    # Given
    user = create_user(plan=Plan.PREMIUM)

    # When
    results = [rate_limiter.check(user) for _ in range(120)]

    # Then - premium gets burst allowance beyond base 100
    assert all(r.allowed for r in results)
```

### GWT maps to AAA

| AAA | GWT | Focus |
|-----|-----|-------|
| Arrange | Given | Preconditions, system state |
| Act | When | Action at the boundary |
| Assert | Then | Expected outcome |

Same structure, different lens. AAA asks "does the code work?" GWT asks "does the system behave correctly?"

### BDD Naming

Name tests from the behavior perspective:

```python
# BDD - describes behavior at boundary
def test_given_expired_token_when_authenticating_then_returns_unauthorized():
def test_given_duplicate_email_when_registering_then_rejects_registration():
def test_given_low_stock_when_ordering_then_creates_backorder():

# Contrast: unit-centric naming (less readable as spec)
def test_auth_service_validate_token():
def test_user_repository_save():
```

### When to Use BDD vs Traditional Unit Tests

| Situation | Use |
|-----------|-----|
| New feature, AI writes implementation | BDD (specs first) |
| Domain logic with complex rules | BDD or unit tests (both work) |
| Bug fix with known reproduction | Unit test (targeted) |
| Internal algorithm correctness | Unit test (classical) |
| Service/API boundary behavior | BDD |

## Test Naming

**Format:** `test_[unit]_[scenario]_[expected_result]`

```python
# Good names
def test_order_with_discount_applies_percentage():
def test_user_with_invalid_email_raises_validation_error():
def test_empty_cart_returns_zero_total():

# Bad names
def test_order():
def test_calculate():
def test_1():
```

## Test Structure (AAA)

```python
def test_user_registration():
    # Arrange - set up preconditions
    email = "alice@example.com"
    password = "secure123"

    # Act - execute the behavior
    user = register_user(email, password)

    # Assert - verify the outcome
    assert user.email == email
    assert user.is_active
```

**Rules:**
- Single Act per test
- No logic in Assert (no if statements)
- Avoid multiple Arrange-Act-Assert cycles

## Testing AI-Generated Code

BDD is the natural fit when AI writes the implementation. You verify **requirements**, not implementation patterns.

### Workflow

1. **Write behavior specs first** — GWT tests define what the system must do
2. **AI generates implementation** — code that satisfies the specs
3. **Run tests** — readable output shows pass/fail per behavior
4. **Verify at a glance** — BDD naming makes acceptance immediate

### Why BDD for AI Code

| Concern | Traditional Tests | BDD Tests |
|---------|-------------------|-----------|
| What you verify | Logic correctness | Requirements met |
| Test output | Method-level pass/fail | Behavior-level pass/fail |
| Acceptance | "Does it work?" | "Does it do what I asked?" |
| Spec reuse | Tests written after code | Tests ARE the spec |

### Spec-First Example

Write this BEFORE asking AI to implement:

```python
class DescribeNotificationService:
    def test_given_user_prefers_email_when_notifying_then_sends_email(self):
        ...

    def test_given_user_prefers_sms_when_notifying_then_sends_sms(self):
        ...

    def test_given_unsubscribed_user_when_notifying_then_skips_silently(self):
        ...

    def test_given_failed_delivery_when_notifying_then_queues_retry(self):
        ...
```

Then tell AI: "Implement NotificationService to pass these specs."

The test names ARE the requirements. Pass/fail output IS the acceptance report.

## References

- AGENTS.md Testing section for quick rules and glue test guidance
- TDD skill for test-first workflow (this skill covers what/how to test)
- Book: "Unit Testing Principles, Practices, and Patterns" by Vladimir Khorikov
- Thread: @waylybaye on BDD as AI coding's best companion

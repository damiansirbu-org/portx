# PORTX TODO

## Critical Issues

### 1. Make Wrapper Creation Truly Transactional
**Current Problem**: Wrapper creation happens during validation, not after. This is not transactional.

**Current Flow**:
1. Process package A → validate → create wrappers immediately
2. Process package B → validate → create wrappers immediately  
3. If package C fails validation, packages A & B already have wrappers created

**Required Flow**:
1. **Phase 1 - Validation**: Validate ALL packages first, collect errors
2. **Phase 2 - Cleanup**: Delete existing wrappers (with announcement of count deleted)
3. **Phase 3 - Creation**: Create all wrappers only if ALL validations passed

**Benefits**:
- True transactional operation
- No partial state if validation fails
- Clear separation of concerns
- Better error reporting

**Implementation**:
- Separate `validate_all_packages()` phase that builds a list of valid packages
- Separate `cleanup_existing_wrappers()` with count announcement
- Separate `create_all_wrappers()` phase that processes the validated list
- If any validation fails, abort before cleanup/creation phases

**Priority**: High - This affects reliability and user experience

### 2. Improve Cleanup Messaging
**Current**: Silent deletion of existing wrappers
**Required**: Announce wrapper cleanup with counts
```
Cleaning up existing PORTX wrappers...
  Removed 234 bash wrappers from /c/App/Git/bin/
  Removed 234 cmd wrappers from /c/App/Git/cmd/
  Total: 468 old wrappers removed
```

**Priority**: Medium
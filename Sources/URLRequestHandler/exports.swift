@_exported import Dependencies
@_exported import IssueReporting
@_exported import LoggingExtras

#if canImport(FoundationNetworking)
  @_exported import FoundationNetworking
#endif

// Test function to verify swift-format auto-commit
func testFormattingTrigger() {
  let x = 1
  let y = 2
  let z = x + y
  print(z)
}

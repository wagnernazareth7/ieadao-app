bool hasPermission({
  required List<String> userPermissions,
  required String requiredPermission,
}) {
  return userPermissions.contains(requiredPermission);
}

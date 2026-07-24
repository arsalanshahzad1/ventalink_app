class UserRoles {
  static const String admin = 'admin';
  static const String user = 'user';
  static const String merchant = 'merchant';
  static const String seller = 'seller';
}

bool isAdminRole(String? role) => role == UserRoles.admin;

bool isStoreRole(String? role) => role == UserRoles.merchant || role == UserRoles.seller;

bool isCustomerRole(String? role) => role == UserRoles.user;

String getRoleLabel(String? role) {
  if (isAdminRole(role)) return "Admin";
  if (isStoreRole(role)) return "Store";
  if (isCustomerRole(role)) return "User";
  return "Account";
}

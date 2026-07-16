import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<dynamic>? _admins;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final admins = await adminProvider.getAdmins();
    if (admins != null) {
      setState(() {
        _admins = admins;
      });
    }
  }

  void _showAddAdminDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Admin'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'master', child: Text('Master Admin')),
                  ],
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              return ElevatedButton(
                onPressed: adminProvider.isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final success = await adminProvider.createAdmin({
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'password': passwordController.text,
                            'role': selectedRole,
                          });
                          if (success && mounted) {
                            navigator.pop();
                            _loadAdmins();
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('Admin created successfully')),
                              );
                            }
                          }
                        }
                      },
                child: adminProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditAdminDialog(dynamic admin) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: admin['name']);
    final emailController = TextEditingController(text: admin['email']);
    String selectedRole = admin['role'];
    bool isActive = admin['isActive'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Admin'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'master', child: Text('Master Admin')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Admin can login when active'),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() {
                        isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                return ElevatedButton(
                  onPressed: adminProvider.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final success = await adminProvider.updateAdmin(
                              admin['_id'],
                              {
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'role': selectedRole,
                                'isActive': isActive,
                              },
                            );
                            if (success && mounted) {
                              navigator.pop();
                              _loadAdmins();
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Admin updated successfully')),
                                );
                              }
                            }
                          }
                        },
                  child: adminProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAdmin(dynamic admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.error,
                ),
                onPressed: adminProvider.isLoading
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final success = await adminProvider.deleteAdmin(admin['_id']);
                        if (success && mounted) {
                          navigator.pop();
                          _loadAdmins();
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Admin deleted successfully')),
                            );
                          }
                        }
                      },
                child: adminProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    
    if (!adminProvider.isMasterAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AdminTheme.textLight),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Only Master Admins can access this page',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AdminTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdmins,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading && _admins == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_admins == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AdminTheme.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load admins',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAdmins,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_admins!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AdminTheme.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'No admins found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first admin to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AdminTheme.textMedium,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _admins!.length,
            itemBuilder: (context, index) {
              final admin = _admins![index];
              final isCurrentUser = admin['_id'] == adminProvider.admin?['id'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: admin['role'] == 'master'
                        ? AdminTheme.navyPrimary
                        : AdminTheme.navyLight,
                    child: Icon(
                      admin['role'] == 'master' ? Icons.star : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(admin['name']),
                  subtitle: Text(admin['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: admin['isActive']
                              ? AdminTheme.success.withValues(alpha: 0.1)
                              : AdminTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          admin['role'] == 'master' ? 'MASTER' : 'ADMIN',
                          style: TextStyle(
                            fontSize: 10,
                            color: admin['isActive'] ? AdminTheme.success : AdminTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isCurrentUser) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditAdminDialog(admin),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AdminTheme.error,
                          onPressed: () => _deleteAdmin(admin),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Admin'),
        backgroundColor: AdminTheme.navyPrimary,
      ),
    );
  }
}

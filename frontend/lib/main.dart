import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/colors.dart';
import 'services/auth_service.dart';
import 'utils/auth_storage.dart';
import 'screens/login_screen.dart';
import 'screens/admin/dashboard_admin.dart';
import 'screens/empleado/dashboard_empleado.dart';  // ✅ Agregar esta línea

void main() async {
  // Asegurar que WidgetsFlutterBinding esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar SharedPreferences
  await SharedPreferences.getInstance();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Óptica Güzellik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.azulReal,
        colorScheme: ColorScheme.light(
          primary: AppColors.azulReal,
          secondary: AppColors.turquesa,
        ),
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/admin': (context) => AdminDashboard(),
        '/empleado': (context) => EmpleadoDashboard(),  // ✅ Ruta opcional
      },
      // Android 15+ dibuja la app de borde a borde por defecto: sin este
      // SafeArea, la barra de navegación del sistema queda encima de los
      // botones inferiores (Finalizar Venta, Guardar paciente, etc.) y no
      // se pueden presionar. Solo se protege el borde inferior; el superior
      // se deja igual para no perder los fondos/gradientes bajo la barra
      // de estado, que Scaffold/AppBar ya manejan correctamente.
      builder: (context, child) {
        return SafeArea(
          top: false,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    // Pequeña pausa para mostrar el splash
    await Future.delayed(Duration(seconds: 1));
    
    // Verificar si hay sesión activa usando AuthStorage directamente
    final token = await AuthStorage.getToken();
    
    if (token != null && token.isNotEmpty) {
      // Verificar si el token es válido con el backend
      try {
        final session = await AuthService.checkSession();
        
        if (session['loggedIn'] == true) {
          final user = session['user'];
          final rol = user != null ? user['rol'] : '';

          if (rol == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboard()),
            );
          } else {
            // ✅ Redirigir al dashboard de empleado
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EmpleadoDashboard()),
            );
          }
        } else {
          await AuthStorage.clearSession();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      } catch (e) {
        await AuthStorage.clearSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azulReal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/Guzellik.jpeg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.visibility,
                    size: 60,
                    color: AppColors.azulReal,
                  );
                },
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Óptica Güzellik',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
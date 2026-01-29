# 📱 Gestor Financiero – App Android

Aplicación **Android** desarrollada en **Flutter** para la gestión de finanzas personales.  
La app consume una **API REST propia** desarrollada en **C# con .NET**, permitiendo administrar ingresos y gastos de forma centralizada.

Este proyecto forma parte de un desarrollo personal orientado al **aprendizaje y portfolio**, integrando frontend móvil y backend.

---

## 📌 Descripción

Gestor Financiero es una aplicación móvil Android que permite llevar el control de las finanzas personales mediante el consumo de una API REST.  
La app se comunica con el backend para realizar operaciones CRUD sobre entidades financieras y mostrar la información de forma clara e intuitiva.

---

## 🔗 Backend (API)

La aplicación consume la siguiente API REST:

👉 **Repositorio:**  
https://github.com/codewitheduardo/gestor-financiero-api

La API está desarrollada en **C# con .NET Web API** y aplica buenas prácticas de arquitectura y seguridad.

---

## 🛠️ Tecnologías utilizadas

### 📱 Frontend (App)
- Flutter
- Dart
- Consumo de APIs REST
- Android (solo Android)

### 🧠 Backend (API)
- C#
- .NET Web API
- REST
- Arquitectura por capas
- BCrypt (hash de contraseñas)
- Consumo de API externa (tipo de cambio)

---

## 🚀 Funcionalidades de la app

- Consumo de endpoints REST
- Gestión de movimientos financieros (ingresos y gastos)
- Operaciones CRUD sobre entidades financieras
- Visualización del balance general
- Integración con backend propio desarrollado en .NET
- Base preparada para autenticación y mejoras futuras

---

## 📥 Instalación y ejecución

### Requisitos previos
- Flutter SDK instalado
- Android Studio (emulador) o dispositivo físico
- API backend en ejecución

---

### Clonar el repositorio

```bash
git clone https://github.com/codewitheduardo/gestor_financiero-app.git

cd gestor_financiero-app

```

2. Instalar dependencias:

```bash
flutter pub get
```

3. Ejecutar la aplicación:

```bash
flutter run
```

4. Ejecutar la API:

```bash
dotnet run
```

> La API debe estar corriendo (local o remota) para que la app funcione correctamente.

---

## 🛠️ Uso

Con la API en ejecución, los endpoints pueden consumirse utilizando herramientas como **Postman**, **Insomnia** o **curl**.


---

## 📁 Estructura del proyecto

```bash
├── android/        # Configuración Android
├── lib/            # Código fuente Flutter
├── assets/         # Recursos gráficos
├── test/           # Tests
├── pubspec.yaml    # Dependencias
└── README.md
```

---

## 🚧 Estado del proyecto

🟢 Activo

Aplicación funcional en desarrollo activo, enfocada en el aprendizaje y la integración entre frontend móvil y backend mediante una API REST propia.

---

## ✍️ Autor

**Eduardo Monzón**  
GitHub: https://github.com/codewitheduardo

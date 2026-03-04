@echo off
REM Campus Management App - Complete Startup Script for Windows

echo.
echo ========================================
echo Campus Management App - Startup Helper
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "backend" (
    echo ERROR: Please run this script from the root project directory
    echo Expected to find 'backend' folder
    pause
    exit /b 1
)

echo Select how you want to start the services:
echo.
echo 1. Start Backend with Docker Compose (Recommended)
echo 2. Start Backend locally with Node.js
echo 3. Start both Backend and Frontend
echo 4. Just show Frontend instructions
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo Starting Backend with Docker Compose...
    echo This will start:
    echo  - API Server on http://localhost:5000/api/v1
    echo  - MongoDB on localhost:27017
    echo  - Mongo Express on http://localhost:8081
    echo.
    
    cd backend
    docker-compose up -d
    
    echo.
    echo Backend services started!
    echo Waiting for services to be ready...
    timeout /t 5
    
    echo.
    echo Backend Status:
    docker-compose ps
    
    cd ..
    
    echo.
    echo Next steps:
    echo 1. Open another terminal in the project root
    echo 2. Run: flutter run
    echo.
    pause
    goto end
)

if "%choice%"=="2" (
    echo.
    echo Starting Backend with Node.js locally...
    echo.
    
    cd backend
    
    if not exist "node_modules" (
        echo Installing dependencies...
        call npm install
    )
    
    echo.
    echo Starting server...
    call npm run dev
    
    cd ..
    goto end
)

if "%choice%"=="3" (
    echo.
    echo Note: This will open two new terminal windows
    echo.
    
    REM Start backend
    echo Starting Backend...
    start cmd /k "cd backend && docker-compose up"
    
    echo Waiting for backend to start...
    timeout /t 10
    
    REM Start frontend
    echo Starting Frontend...
    start cmd /k "flutter run"
    
    echo.
    echo Both services should now be starting...
    echo.
    pause
    goto end
)

if "%choice%"=="4" (
    echo.
    echo To start the Flutter app:
    echo 1. Make sure backend is running on http://localhost:5000
    echo 2. Connect a device or start an emulator
    echo 3. Run: flutter run
    echo.
    pause
    goto end
)

echo Invalid choice!
pause

:end
echo.
echo For more information, see:
echo - backend/README.md - Backend documentation
echo - backend/QUICK_START.md - Backend quick start
echo - BACKEND_INTEGRATION.md - Integration guide
echo.

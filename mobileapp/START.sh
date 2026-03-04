#!/bin/bash

# Campus Management App - Complete Startup Script for Mac/Linux

echo ""
echo "========================================"
echo "Campus Management App - Startup Helper"
echo "========================================"
echo ""

# Check if we're in the right directory
if [ ! -d "backend" ]; then
    echo "ERROR: Please run this script from the root project directory"
    echo "Expected to find 'backend' folder"
    exit 1
fi

echo "Select how you want to start the services:"
echo ""
echo "1. Start Backend with Docker Compose (Recommended)"
echo "2. Start Backend locally with Node.js"
echo "3. Start both Backend and Frontend"
echo "4. Just show Frontend instructions"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "Starting Backend with Docker Compose..."
        echo "This will start:"
        echo " - API Server on http://localhost:5000/api/v1"
        echo " - MongoDB on localhost:27017"
        echo " - Mongo Express on http://localhost:8081"
        echo ""
        
        cd backend
        docker-compose up -d
        
        echo ""
        echo "Backend services started!"
        echo "Waiting for services to be ready..."
        sleep 5
        
        echo ""
        echo "Backend Status:"
        docker-compose ps
        
        cd ..
        
        echo ""
        echo "Next steps:"
        echo "1. Open another terminal in the project root"
        echo "2. Run: flutter run"
        echo ""
        ;;
    
    2)
        echo ""
        echo "Starting Backend with Node.js locally..."
        echo ""
        
        cd backend
        
        if [ ! -d "node_modules" ]; then
            echo "Installing dependencies..."
            npm install
        fi
        
        echo ""
        echo "Starting server..."
        npm run dev
        
        cd ..
        ;;
    
    3)
        echo ""
        echo "Note: This will open new terminal windows"
        echo ""
        
        # Start backend in new terminal
        echo "Starting Backend..."
        (cd backend && docker-compose up) &
        
        echo "Waiting for backend to start..."
        sleep 10
        
        # Start frontend in new terminal
        echo "Starting Frontend..."
        flutter run &
        
        echo ""
        echo "Both services should now be starting..."
        echo ""
        ;;
    
    4)
        echo ""
        echo "To start the Flutter app:"
        echo "1. Make sure backend is running on http://localhost:5000"
        echo "2. Connect a device or start an emulator"
        echo "3. Run: flutter run"
        echo ""
        ;;
    
    *)
        echo "Invalid choice!"
        ;;
esac

echo ""
echo "For more information, see:"
echo "- backend/README.md - Backend documentation"
echo "- backend/QUICK_START.md - Backend quick start"
echo "- BACKEND_INTEGRATION.md - Integration guide"
echo ""

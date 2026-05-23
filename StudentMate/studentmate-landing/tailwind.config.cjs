/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './index.html',
    './src/**/*.{ts,tsx,js,jsx}'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        deepblue: '#071033',
        royalblue: '#2246ff',
        electric: '#4cc9ff',
        neonpurple: '#8a2be2'
      },
      keyframes: {
        floaty: {
          '0%': { transform: 'translateY(0px) scale(1)' },
          '50%': { transform: 'translateY(-18px) scale(1.02)' },
          '100%': { transform: 'translateY(0px) scale(1)' }
        },
        gradientShift: {
          '0%': { 'background-position': '0% 50%' },
          '50%': { 'background-position': '100% 50%' },
          '100%': { 'background-position': '0% 50%' }
        },
        shimmer: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(100%)' }
        }
      },
      animation: {
        floaty: 'floaty 6s ease-in-out infinite',
        gradientShift: 'gradientShift 12s ease infinite',
        shimmer: 'shimmer 2.2s linear infinite'
      },
      backgroundImage: {
        'cool-gradient': 'linear-gradient(90deg, #0b1226 0%, #1b2a6b 25%, #4b2a99 50%, #2b1b79 75%, #08102a 100%)'
      }
    }
  },
  plugins: []
}

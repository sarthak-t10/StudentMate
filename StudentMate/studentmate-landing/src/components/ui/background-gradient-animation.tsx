import React from 'react'

const BackgroundGradientAnimation: React.FC = () => {
  return (
    <div className="absolute inset-0 -z-10 overflow-hidden">
      <div
        className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_left,_#0b1026_0%,_transparent_30%)] opacity-70 animate-gradientShift"
        style={{
          backgroundSize: '300% 300%'
        }}
      />

      <div className="absolute -left-40 top-20 w-96 h-96 rounded-full bg-purple-700/30 blur-3xl animate-floaty" />
      <div className="absolute right-[-6rem] top-56 w-72 h-72 rounded-full bg-blue-600/30 blur-2xl animate-[floaty_8s_ease-in-out_infinite]" />

      <div className="absolute inset-0 pointer-events-none">
        <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
          <defs>
            <filter id="glow">
              <feGaussianBlur stdDeviation="30" result="coloredBlur" />
              <feMerge>
                <feMergeNode in="coloredBlur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
          </defs>
        </svg>
      </div>
    </div>
  )
}

export default BackgroundGradientAnimation

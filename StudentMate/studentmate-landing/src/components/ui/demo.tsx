import React from 'react'
import BackgroundGradientAnimation from './background-gradient-animation'

export const DemoLayout: React.FC<{ children?: React.ReactNode }> = ({ children }) => {
  return (
    <div className="relative min-h-screen w-full overflow-hidden">
      <BackgroundGradientAnimation />
      <div className="relative z-10">{children}</div>
    </div>
  )
}

export default DemoLayout

import React from 'react'
import DemoLayout from './components/ui/demo'
import Navbar from './components/Navbar'
import Hero from './components/Hero'
import FeaturesGrid from './components/FeaturesGrid'

const App: React.FC = () => {
  return (
    <DemoLayout>
      <Navbar />
      <main className="pt-28">
        <Hero />
        <FeaturesGrid />
      </main>
    </DemoLayout>
  )
}

export default App

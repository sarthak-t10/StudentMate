import React from 'react'
import { motion } from 'framer-motion'
import { cn } from '../lib/utils'

const Nav: React.FC = () => {
  return (
    <motion.nav
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6 }}
      className="fixed top-6 left-0 right-0 mx-auto max-w-6xl px-6 flex items-center justify-between glass border border-white/6 backdrop-blur-md shadow-md z-20"
    >
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-md bg-gradient-to-br from-royalblue to-neonpurple flex items-center justify-center text-white font-bold">SM</div>
        <div className="font-semibold tracking-wider">StudentMate</div>
      </div>

      <div className="hidden md:flex items-center gap-6">
        <a className="text-sm hover:underline">Home</a>
        <a className="text-sm hover:underline">Features</a>
        <a className="text-sm hover:underline">About</a>
        <button className="px-3 py-1 rounded-md bg-white/6 glass">Login</button>
      </div>
    </motion.nav>
  )
}

export default Nav

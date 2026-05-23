import React from 'react'
import { motion } from 'framer-motion'
import { ArrowRight } from 'lucide-react'

const Hero: React.FC = () => {
  return (
    <section className="min-h-screen flex items-center justify-center">
      <div className="max-w-4xl mx-auto px-6 text-center">
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.8 }}
          className="text-6xl md:text-8xl font-extrabold leading-tight bg-clip-text text-transparent bg-gradient-to-r from-blue-300 via-purple-400 to-indigo-200"
        >
          STUDENTMATE
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4, duration: 0.8 }}
          className="mt-4 text-xl text-slate-300"
        >
          Your Smart Academic Companion
        </motion.p>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.8 }}
          className="mt-6 text-slate-400 max-w-2xl mx-auto"
        >
          Manage notes, tasks, schedules, attendance and boost productivity with intelligent
          tools built for students.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9 }}
          className="mt-8 flex items-center justify-center gap-4"
        >
          <a
            href="#"
            className="inline-flex items-center gap-3 px-6 py-3 rounded-2xl bg-gradient-to-r from-royalblue to-neonpurple text-white shadow-lg transform hover:scale-105 transition">
            Get Started <ArrowRight size={16} />
          </a>

          <a href="#features" className="px-5 py-3 rounded-2xl border border-white/6 glass text-slate-200">
            Explore Features
          </a>
        </motion.div>
      </div>
    </section>
  )
}

export default Hero

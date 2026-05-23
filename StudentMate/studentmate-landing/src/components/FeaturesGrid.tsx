import React from 'react'
import { BookOpen, Calendar, CheckSquare, ListChecks, PieChart, FileText } from 'lucide-react'
import { motion } from 'framer-motion'

const features = [
  { title: 'Task Management', icon: <ListChecks /> },
  { title: 'Attendance Tracker', icon: <CheckSquare /> },
  { title: 'Smart Notes', icon: <FileText /> },
  { title: 'Exam Planner', icon: <Calendar /> },
  { title: 'Schedule Organizer', icon: <BookOpen /> },
  { title: 'Productivity Analytics', icon: <PieChart /> }
]

const FeaturesGrid: React.FC = () => {
  return (
    <section id="features" className="py-16">
      <div className="max-w-6xl mx-auto px-6">
        <h3 className="text-3xl font-semibold mb-8">Features Preview</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              whileHover={{ y: -6, scale: 1.02 }}
              transition={{ type: 'spring', stiffness: 200 }}
              className="glass border border-white/6 p-6 rounded-xl shadow-md"
            >
              <div className="flex items-center gap-4">
                <div className="p-3 rounded-lg bg-gradient-to-br from-blue-500 to-purple-600 text-white">
                  {React.cloneElement(f.icon as any, { size: 20 })}
                </div>
                <div>
                  <div className="font-semibold">{f.title}</div>
                  <div className="text-sm text-slate-300">Smart tools tailored for students.</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default FeaturesGrid

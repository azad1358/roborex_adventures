
import { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'

function App() {
  const [status, setStatus] = useState('Checking connection...')

  useEffect(() => {
    async function checkConnection() {
      const { error } = await supabase
        .from('connection_test')
        .select('*')
        .limit(1)

      if (error?.code === '42P01' || error?.code === 'PGRST205') {
        setStatus('Connected to Supabase! Test table not created yet.')
      } else if (error) {
        setStatus(`Supabase responded: ${error.message}`)
      } else {
        setStatus('Connected to Supabase successfully!')
      }
    }

    checkConnection()
  }, [])

  return (
    <main style={{ padding: 32, fontFamily: 'Arial, sans-serif' }}>
      <h1>RoboRex Adventures</h1>
      <p>{status}</p>
    </main>
  )
}

export default App

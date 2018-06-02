ExUnit.configure(exclude: [external: true])
ExUnit.start()
AcmeEx.Standalone.start_link()
Logger.configure(level: :warn)

defmodule AcmeEx.Apps do
  def start() do
    {:ok, _pid} = Plug.Adapters.Cowboy2.http(AcmeEx.Website, [], port: 4848)
    {:ok, _pid} = Plug.Adapters.Cowboy2.http(AcmeEx.Cms, [], port: 4849)
    {:ok, _pid} = Plug.Adapters.Cowboy2.http(AcmeEx.Blog, [], port: 4850)
  end

  def stop() do
    Plug.Adapters.Cowboy2.shutdown(AcmeEx.Website.HTTP)
    Plug.Adapters.Cowboy2.shutdown(AcmeEx.Cms.HTTP)
    Plug.Adapters.Cowboy2.shutdown(AcmeEx.Blog.HTTP)
  end
end

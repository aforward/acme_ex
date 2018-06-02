defmodule AcmeEx.Apps do
  def start() do
    cowboy = AcmeEx.Router.adapter([])
    {:ok, _pid} = apply(cowboy, :http, [AcmeEx.Website, [], [port: 4848]])
    {:ok, _pid} = apply(cowboy, :http, [AcmeEx.Cms, [], [port: 4849]])
    {:ok, _pid} = apply(cowboy, :http, [AcmeEx.Blog, [], [port: 4850]])
  end

  def stop() do
    cowboy = AcmeEx.Router.adapter([])
    apply(cowboy, :shutdown, [AcmeEx.Website.HTTP])
    apply(cowboy, :shutdown, [AcmeEx.Cms.HTTP])
    apply(cowboy, :shutdown, [AcmeEx.Blog.HTTP])
  end
end

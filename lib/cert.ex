defmodule AcmeEx.Cert do
  def generate!(request, id) do
    try do
      request
      |> generate(id)
      |> (& &1.crt).()
      |> File.read!()
    after
      clean(id)
    end
  end

  def generate(request, {order, _account} = id) do
    id
    |> files()
    |> (fn files ->
          File.write!(files.index, "")
          File.write!(files.serial, "01")
          File.write!(files.caconfig, caconfig(files))
          File.write!(files.ext, ext(order.domains))
          gen_ca_keys!(files)
          write_der!(files, request)
          gen_pem!(files)
          gen_crt!(files, order.domains)
          files
        end).()
  end

  def clean({_order, _account} = id) do
    id
    |> folder()
    |> File.rm_rf()
  end

  def folder({order, account}) do
    {account.id, order.id}
    |> :erlang.term_to_binary()
    |> Base.url_encode64(padding: false)
    |> (fn folder_name ->
          AcmeEx.dir()
          |> Path.join("tmp")
          |> Path.join(folder_name)
        end).()
  end

  def files({_order, _account} = id) do
    id
    |> folder()
    |> (fn folder ->
          File.mkdir_p!(folder)

          [:der, :csr, :crt, :ext, :caconfig, :cakey, :cacert, :index, :serial]
          |> Enum.map(&{&1, Path.join(folder, "#{&1}")})
          |> Map.new()
          |> Map.put(:folder, folder)
        end).()
  end

  def cmd!(args) do
    {_, 0} = cmd(args)
    :ok
  end

  def cmd(args) do
    System.cmd("openssl", args, stderr_to_stdout: true)
  end

  defp caconfig(files) do
    """
    [ ca ]
    default_ca = my_ca

    [ my_ca ]
    serial = #{files.serial}
    database = #{files.index}
    new_certs_dir = #{files.folder}
    certificate = #{files.cacert}
    private_key = #{files.cakey}
    default_md = sha1
    default_days = 1
    policy = my_policy

    [ my_policy ]
    countryName = optional
    stateOrProvinceName = optional
    organizationName = optional
    commonName = optional
    organizationalUnitName = optional
    commonName = optional
    """
  end

  defp ext(domains) do
    "subjectAltName=#{domains |> Enum.map(&"DNS:#{&1}") |> Enum.join(",")}"
  end

  defp write_der!(files, request) do
    request.payload
    |> Map.fetch!("csr")
    |> Base.url_decode64!(padding: false)
    |> (fn csr -> File.write!(files.der, csr) end).()
  end

  defp gen_ca_keys!(files) do
    cmd!(~w(
      req -new -newkey rsa:4096 -nodes -x509
      -subj /C=US/ST=State/L=Location/O=Org/CN=localhost
      -keyout #{files.cakey} -out #{files.cacert}
    ))
  end

  defp gen_pem!(files) do
    cmd!(~w(req -inform der -in #{files.der} -out #{files.csr}))
  end

  defp gen_crt!(files, domains) do
    cmd!(~w(
        ca -batch -subj /CN=#{hd(domains)} -config #{files.caconfig} -extfile #{files.ext}
        -out #{files.crt} -infiles #{files.csr}
      ))
  end
end

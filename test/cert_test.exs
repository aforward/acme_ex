defmodule CertTest do
  use ExUnit.Case, async: true
  alias AcmeEx.Cert

  @id {%{id: 11, domains: ["foo.com", "foo.ca"]}, %{id: 10}}
  @folder "g2gCYQphCw"
  @request %{
    payload: %{
      "csr" =>
        "MIIChTCCAW0CAQIwADCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALaPgrNygsHTAsQ37v1nKmuhAUnqi_wPgqp_9982RWzvF0zwKru1FPNhoRkbGSnNjD1oToGBlWaE5bDUkZZ0GAmVxjH3Vn4B3s0N09dO1r5wYrKMjHZfUKiM6nsvqoFjRielhwl3OhV1nqbbJFc9dRqQ9PsLa-dU-7jmdBDH65qxnh1i-O4V8-lI1TPuRg8WGZZ5yq7LFzHFs7yJ77WzDrZlWKu3W20zE0InxFuQmHH2sPOu9rQM79iEzOXvjclR9fy9tFi-pgALznQF16Z9KF-qtzQdKiksZMORZoBKbv115scTlHqvCv089wLsMeDsxoFAiGgIW2gq5IUXOtuKmb0CAwEAAaBAMD4GCSqGSIb3DQEJDjExMC8wLQYDVR0RBCYwJIIHZm9vLmJhcoILd3d3LmZvby5iYXKCDGJsb2cuZm9vLmJhcjANBgkqhkiG9w0BAQsFAAOCAQEALDPpiFoil4Pb5CxxzDtaafKM7HDknwP_UPI2EU_Vvw2kCxWPf0YCKzMyBZOlIrvd6HKfRi4AtJ-wBnBmAOWGgQ3bqgLJTAP3Z9Xwp8DaGCBsUkCz7shstw6IFe0slmZSIpP29noE4gwh4JOygYWKX_hjuJzExDkEYDdykjlkgzwJR6PYBj87NJLLCbQ5LM2XsOm74S6L-kWY1tM_pvAAf5fCaqrauBYOrH_RVh038mHCcWRjW7kc-FJgG36vY95BlxrJeGH5RCqiGKcHTIIH4rTbJjOikifD6KRI43nYw8PTMGMfR6rbcKFwEP-kdWhUPJDaDJMzf_jX8z2-3jaRMQ",
      "resource" => "new-cert"
    }
  }

  setup _context do
    Cert.clean({%{id: 11}, %{id: 10}})
    :ok
  end

  test "cmd" do
    {_, return} = Cert.cmd(["version"])
    assert return == 0
  end

  test "folder" do
    assert "#{AcmeEx.dir()}/tmp/#{@folder}" == Cert.folder(@id)
  end

  test "files" do
    assert %{
             cacert: "#{AcmeEx.dir()}/tmp/#{@folder}/cacert",
             caconfig: "#{AcmeEx.dir()}/tmp/#{@folder}/caconfig",
             cakey: "#{AcmeEx.dir()}/tmp/#{@folder}/cakey",
             crt: "#{AcmeEx.dir()}/tmp/#{@folder}/crt",
             csr: "#{AcmeEx.dir()}/tmp/#{@folder}/csr",
             der: "#{AcmeEx.dir()}/tmp/#{@folder}/der",
             ext: "#{AcmeEx.dir()}/tmp/#{@folder}/ext",
             folder: "#{AcmeEx.dir()}/tmp/#{@folder}",
             index: "#{AcmeEx.dir()}/tmp/#{@folder}/index",
             serial: "#{AcmeEx.dir()}/tmp/#{@folder}/serial"
           } == Cert.files(@id)
  end

  @tag :external
  test "generate" do
    files = Cert.generate(@request, @id)

    assert "02\n" == File.read!(files.serial)
    assert "subjectAltName=DNS:foo.com,DNS:foo.ca" == File.read!(files.ext)

    assert "" != File.read!(files.index)
    assert "" != File.read!(files.cakey)
    assert "" != File.read!(files.cacert)
    assert "" != File.read!(files.der)
    assert "" != File.read!(files.crt)

    assert """
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
           """ == File.read!(files.caconfig)
  end

  @tag :external
  test "generate!" do
    crt = Cert.generate!(@request, @id)

    assert crt |> String.starts_with?("Certificate:")
    assert !File.dir?(Cert.folder(@id))
  end
end

defmodule LivroDeRegistrosDeContatos do
  alias LivroDeRegistrosDeContatos.{Contacts, Store}

  def main(_args \\ []) do
    IO.puts("========================================")
    IO.puts("   LIVRO DE REGISTROS DE CONTATOS")
    IO.puts("========================================")
    IO.puts("Comandos: add, list, show <id>, search, del <id>, edit <id>, exit")

    loop()
  end

  defp loop do
    input = IO.gets("\n> ") |> String.trim()

    input
    |> parse_input()
    |> handle_command()
  end

  defp parse_input(input) do
    case OptionParser.split(input) do
      [command | args] -> {String.downcase(command), args}
      [] -> {"", []}
    end
  end

  defp handle_command({"exit", _args}) do
    IO.puts("Encerrando o programa. Até mais!")
  end

  defp handle_command({"add", args}) do
    case parse_flags(args) do
      {:ok, data} ->
        Store.load()
        |> Contacts.add(data)
        |> Store.save()

        IO.puts(" Contato adicionado com sucesso!")

      {:error, msg} ->
        IO.puts(" Erro: #{msg}")

        IO.puts(
          "Uso: add --name \"Ana\" --company \"Acme\" --phone \"123\" --email \"ana@mail.com\""
        )
    end

    loop()
  end

  defp handle_command({"list", _args}) do
    Store.load()
    |> display_contacts()

    loop()
  end

  defp handle_command({cmd, ["<id>" | _]}) when cmd in ["show", "del", "edit"] do
    IO.puts("!! Aviso: '<id>' é apenas um exemplo. Digite o número real (ex: #{cmd} 1714429580)")
    loop()
  end

  defp handle_command({"show", [id_str | _]}) do
    case Integer.parse(id_str) do
      {id, _} ->
        Store.load()
        |> Contacts.get_by_id(id)
        |> display_single_contact()

      :error ->
        IO.puts(" Erro: O ID deve ser um número. Use 'list' para ver os IDs válidos.")
    end

    loop()
  end

  defp handle_command({"show", []}) do
    IO.puts(" Erro: Comando incompleto. Uso correto: show <id>")
    loop()
  end

  defp handle_command({"search", args}) do
    case parse_search(args) do
      {:ok, query} ->
        Store.load()
        |> Contacts.search(query)
        |> display_search_results()

      {:error, msg} ->
        IO.puts("X #{msg}")
    end

    loop()
  end

  defp handle_command({"del", [id_str | _]}) do
    case Integer.parse(id_str) do
      {id, _} ->
        contacts = Store.load()

        if Enum.any?(contacts, fn c -> c.id == id end) do
          contacts
          |> Contacts.delete(id)
          |> Store.save()

          IO.puts(" Contato removido com sucesso!")
        else
          IO.puts(" Erro: Contato com ID #{id} não encontrado.")
        end

      :error ->
        IO.puts(" Erro: ID inválido. Deve ser um número.")
    end

    loop()
  end

  defp handle_command({"del", []}) do
    IO.puts(" Erro: Uso correto: del <id>")
    loop()
  end

  defp handle_command({"edit", [id_str | flag_args]}) do
    case Integer.parse(id_str) do
      {id, _} ->
        updates = extract_flags(flag_args, %{})

        cond do
          flag_args == [] ->
            IO.puts(
              " Erro: Nenhuma informação informada para editar. Uso: edit <id> --flag valor"
            )

          updates == %{} ->
            IO.puts(
              " Erro: Nenhuma flag válida encontrada. Use: --name, --company, --phone ou --email"
            )

          true ->
            contacts = Store.load()

            if Enum.any?(contacts, fn c -> c.id == id end) do
              contacts
              |> Contacts.edit(id, updates)
              |> Store.save()

              IO.puts(" Contato atualizado com sucesso!")
            else
              IO.puts(" Erro: Contato com ID #{id} não encontrado.")
            end
        end

      :error ->
        IO.puts(" Erro: ID inválido. Deve ser um número.")
    end

    loop()
  end

  defp handle_command({"edit", []}) do
    IO.puts(" Erro: Uso correto: edit <id> --flags...")
    loop()
  end

  defp handle_command({command, _args}) do
    IO.puts(" Comando inválido: '#{command}'")
    IO.puts(" Comandos disponíveis: add, list, show, search, del, edit, exit")
    loop()
  end

  defp parse_flags(args) do
    data = extract_flags(args, %{})
    required = [:name, :company, :phone, :email]
    missing = Enum.filter(required, fn field -> !Map.has_key?(data, field) end)

    if missing == [] do
      {:ok, data}
    else
      {:error, "Faltam os campos obrigatórios: #{Enum.join(missing, ", ")}"}
    end
  end

  defp extract_flags([], acc), do: acc

  defp extract_flags(["--name", val | rest], acc),
    do: extract_flags(rest, Map.put(acc, :name, val))

  defp extract_flags(["--company", val | rest], acc),
    do: extract_flags(rest, Map.put(acc, :company, val))

  defp extract_flags(["--phone", val | rest], acc),
    do: extract_flags(rest, Map.put(acc, :phone, val))

  defp extract_flags(["--email", val | rest], acc),
    do: extract_flags(rest, Map.put(acc, :email, val))

  defp extract_flags([_unknown | rest], acc), do: extract_flags(rest, acc)

  defp parse_search(args) do
    result =
      case args do
        [flag, val] when flag in ["--name", "--phone", "--email"] ->
          field = String.replace(flag, "--", "") |> String.to_atom()
          {:ok, {field, val}}

        [] ->
          {:error, "Você deve informar uma flag de busca. Ex: search --name Ana"}

        _ ->
          {:error, "Busca inválida. Use apenas UMA flag (--name, --phone ou --email) e um valor."}
      end

    log_data =
      case result do
        {:ok, {field, val}} -> [Atom.to_string(field), val]
        {:error, msg} -> [msg]
      end

    File.write!("lib/parse.json", Jason.encode!(log_data))

    result
  end

  defp display_search_results([]) do
    IO.puts("\n Nenhum contato encontrado.")
  end

  defp display_search_results(contacts) do
    IO.puts("\n Resultados encontrados:")
    display_contacts(contacts)
  end

  defp display_contacts([]) do
    IO.puts("\n📭 A lista de contatos está vazia.")
  end

  defp display_contacts(contacts) do
    IO.puts("\n--- Lista de Contatos ---")

    Enum.each(contacts, fn c ->
      IO.puts("ID: #{c.id} | Nome: #{c.name} | Tel: #{c.phone}")
    end)
  end

  defp display_single_contact(nil) do
    IO.puts("\n Contato não encontrado.")
  end

  defp display_single_contact(c) do
    IO.puts("\n--- Detalhes do Contato ---")
    IO.puts("ID:       #{c.id}")
    IO.puts("Nome:     #{c.name}")
    IO.puts("Empresa:  #{c.company}")
    IO.puts("Telefone: #{c.phone}")
    IO.puts("Email:    #{c.email}")
  end
end

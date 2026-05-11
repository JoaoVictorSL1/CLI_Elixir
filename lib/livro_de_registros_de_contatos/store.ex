defmodule LivroDeRegistrosDeContatos.Store do
  @file_path "contacts.json"

  def load do
    if File.exists?(@file_path) do
      case File.read(@file_path) do
        {:ok, content} -> 
          Jason.decode!(content, keys: :atoms)
        _ -> []
      end
    else
      []
    end
  end

  def save(contacts) do
    content = Jason.encode!(contacts, pretty: true)
    File.write!(@file_path, content)
  end
end

defmodule LivroDeRegistrosDeContatos.Contacts do
  def add(contacts, data) when is_list(contacts) and is_map(data) do
    new_contact = Map.put(data, :id, System.system_time(:millisecond))
    [new_contact | contacts]
  end

  def get_by_id(contacts, id) do
    Enum.find(contacts, fn contact -> contact.id == id end)
  end

  def search(contacts, {field, value}) do
    search_term = String.downcase(value)

    Enum.filter(contacts, fn contact ->
      contact_value = Map.get(contact, field) |> to_string() |> String.downcase()
      String.contains?(contact_value, search_term)
    end)
  end

  def delete(contacts, id) do
    Enum.reject(contacts, fn contact -> contact.id == id end)
  end

  def edit(contacts, id, updates) do
    Enum.map(contacts, fn contact ->
      if contact.id == id do
        Map.merge(contact, updates)
      else
        contact
      end
    end)
  end
end

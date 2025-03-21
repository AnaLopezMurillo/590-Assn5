defmodule Barbershop do
  def start do
    IO.puts("Starting the barbershop!")

    # Spawn barber and receptionist processes
    barber = spawn(fn -> barber_loop([]) end)
    receptionist = spawn(fn -> receptionist_loop(barber, []) end)

    # Start generating customers
    spawn(fn -> generate_customers(receptionist) end)

    # Keep the main process alive
    Process.sleep(:infinity)
  end

  # Barber Process: Handles customers waiting in queue
  defp barber_loop([]) do
    IO.puts("No customers. Barber is sleeping...")

    receive do
      {:next_customer, [next | rest]} ->
        IO.puts("Barber is cutting hair for customer #{next}.")
        :timer.sleep(:rand.uniform(3000))  # Simulating haircut
        IO.puts("Customer #{next} is done. Barber is available.")
        barber_loop(rest)  # Continue with next customer

      _ ->
        barber_loop([])
    end
  end

  defp barber_loop(waiting_list) do
    receive do
      {:next_customer, [next | rest]} ->
        IO.puts("Barber is cutting hair for customer #{next}.")
        :timer.sleep(:rand.uniform(3000))  # Simulating haircut
        IO.puts("Customer #{next} is done. Barber is available.")
        barber_loop(rest)

      _ ->
        barber_loop(waiting_list)
    end
  end

  # Receptionist Process: Handles customer arrivals
  defp receptionist_loop(barber, waiting_list) do
    receive do
      {:customer, id} ->
        IO.puts("Customer #{id} arrives at the shop.")

        if length(waiting_list) < 6 do
          IO.puts("Customer #{id} is waiting.")
          new_list = waiting_list ++ [id]

          # Wake up barber if he's idle
          if waiting_list == [] do
            send(barber, {:next_customer, new_list})
          end

          receptionist_loop(barber, new_list)
        else
          IO.puts("No chairs available. Customer #{id} leaves.")
          receptionist_loop(barber, waiting_list)
        end
    end
  end

  # Customer Generator Process: Keeps creating customers
  defp generate_customers(receptionist) do
    id = :rand.uniform(1000)
    send(receptionist, {:customer, id})
    :timer.sleep(:rand.uniform(3000))  # Customers arrive randomly in interval of 3 secs
    generate_customers(receptionist)  # Keep generating customers
  end
end

Barbershop.start()

defmodule Barbershop do
  def start do
    IO.puts("Starting the barbershop!")

    # Spawn barber and receptionist processes
    barber = spawn(fn -> barber_loop() end)
    receptionist = spawn(fn -> receptionist_loop(barber, []) end)

    # Start generating customers
    spawn(fn -> generate_customers(receptionist) end)

    # Keep the main process alive
    Process.sleep(:infinity)
  end

  # Barber Process: Handles customers waiting in queue
  defp barber_loop do
    receive do
      {:next_customer, customer} ->
        IO.puts("Barber is cutting hair for customer #{customer}.")
        :timer.sleep(:rand.uniform(3000))  # Simulating haircut
        IO.puts("Customer #{customer} is done. Barber is available.")

        # Let's keep the loop going
        barber_loop()
      :no_one_waiting ->
        IO.puts("No customers. Barber is sleeping...")
    end
  end

  # Receptionist process: manages queue
  defp receptionist_loop(barber, waiting_list) do
    receive do
      {:customer, id} ->
        IO.puts("Customer #{id} arrives at the shop.")

        if length(waiting_list) < 6 do
          IO.puts("Customer #{id} is waiting.")
          new_list = waiting_list ++ [id]

          # Wake up barber if he's idle
          if length(waiting_list) == 0 do
            [next | rest] = new_list
            send(barber, {:next_customer, next})
            receptionist_loop(barber, rest)
          else
            receptionist_loop(barber, new_list)
          end
        else
          IO.puts("No chairs available. Customer #{id} leaves.")
          receptionist_loop(barber, waiting_list)
        end
    end
  end

  # Generate customers
  defp generate_customers(receptionist) do
    id = :rand.uniform(1000)
    send(receptionist, {:customer, id})
    :timer.sleep(:rand.uniform(3000))  # Customers arrive randomly
    generate_customers(receptionist)  # loop
  end
end

Barbershop.start()

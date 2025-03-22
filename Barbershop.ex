# team members: Isabel Lopez Murillo and Caitlyn Kim

defmodule Barbershop do
  def start do
    IO.puts("Starting the barbershop!\n")

    # Spawn barber and receptionist processes
    barber = spawn(fn -> barber_loop() end)
    receptionist = spawn(fn -> receptionist_loop(barber, []) end)

    # Start generating customers
    spawn(fn -> generate_customers(receptionist) end)

    # Keep the main process alive
    Process.sleep(:infinity)
  end

  defp barber_loop do
    receive do
      {:next_customer, customer} ->
        IO.puts("Barber is cutting hair for customer #{customer}.")
        :timer.sleep(:rand.uniform(3000))  # Simulating haircut (randomly betwen 0-3 seconds)
        IO.puts("Customer #{customer} is done. Barber is available.\n")
        barber_loop()
      :no_one_waiting ->
        IO.puts("No customers. Barber is sleeping...")
        barber_loop()
    end
  end

  defp receptionist_loop(barber, waiting_list) do
    receive do
      {:customer, id} ->
        IO.puts("Customer #{id} arrives at the shop.")

        case length(waiting_list) do
          0 ->
            send(barber, {:next_customer, id})  # send immediately
            # customer(receptionist_loop)
            send(barber, {:no_one_waiting})     # tell barber he can sleep after this
            receptionist_loop(barber, waiting_list)
          n when n < 5 ->
            IO.puts("Customer #{id} sits in the waiting area.")
            new_list = waiting_list ++ [id]  # add this customer to the waiting list

            [next | rest] = new_list
            send(barber, {:next_customer, next})
            receptionist_loop(barber, rest)
          _ ->
            # waiting list full
            # send(customer, {:rejected, id})
            receptionist_loop(barber, waiting_list)
        end
    end
  end

# customer process that interacts with receptionist
defp customer(receptionist) do
    send(receptionist, {:new_customer, self()})

    receive do
    :served -> IO.puts("Customer got a haircut and is leaving.")
    :rejected -> IO.puts("Customer left due to no available seats.")
    end
end

  defp generate_customers(receptionist) do
    id = :rand.uniform(1000)
    send(receptionist, {:customer, id})
    :timer.sleep(:rand.uniform(3000))  # Customers arrive randomly
    generate_customers(receptionist)  # loop
  end
end

Barbershop.start()

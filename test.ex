# team members: Isabel Lopez Murillo and Caitlyn Kim

defmodule Barbershop do
    # starting the barbershop, initializing barber and receptionist
    def start do
        IO.puts("Starting the barbershop!")
        barber = spawn(__MODULE__, :barber_loop, [])  # spawn barber with hot-swappable loop
        receptionist = spawn(__MODULE__, :receptionist_loop, [barber, []])  # spawn receptionist
        customer_generator(receptionist)  # start generating customers
    end

    # continuously generates customers with the latest version of the module
    def customer_generator(receptionist) do
        spawn(__MODULE__, :customer, [receptionist, self()])
        :timer.sleep(:rand.uniform(5000))
        apply(__MODULE__, :customer_generator, [receptionist])
    end

    # customer process that interacts with receptionist
    def customer(receptionist, _parent) do
        send(receptionist, {:new_customer, self()})
        receive do
        :served -> IO.puts("Customer got a haircut and is leaving.")
        :rejected -> IO.puts("Customer left due to no available seats.")
        end
    end

    # receptionist process handles incoming customers and manages waiting room queue
    def receptionist_loop(barber, queue) do
        receive do
        {:new_customer, customer} ->
            if length(queue) < 6 do
            IO.puts("Customer added to waiting room.")
            send(barber, {:next_customer, customer})
            apply(__MODULE__, :receptionist_loop, [barber, queue ++ [customer]])
            else
            IO.puts("No seats available. Customer turned away.")
            send(customer, :rejected)
            apply(__MODULE__, :receptionist_loop, [barber, queue])
            end
        end
    end

    # barber process handles cutting hair and goes to sleep if idle
    def barber_loop do
        IO.puts("Barber is ready.")
        receive do
        {:next_customer, customer} ->
            IO.puts("Barber is cutting hair.")
            :timer.sleep(:rand.uniform(2000))
            send(customer, :served)
            apply(__MODULE__, :barber_loop, [])  # dynamically reload barber loop
        after 5000 ->
        IO.puts("Barber is sleeping...")
        apply(__MODULE__, :barber_loop, [])  # dynamically reload when sleeping
        end
    end
end

Barbershop.start()

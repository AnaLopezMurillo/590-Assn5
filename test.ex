# team members: Isabel Lopez Murillo and Caitlyn Kim

defmodule Barbershop do
    # starting the barbershop simulation, setting up the barber and receptionist
    def start do
        IO.puts("Starting the barbershop!")

        barber = spawn(__MODULE__, :barber_process, [nil])
        waiting_room = spawn(__MODULE__, :waiting_room_process, [barber, 6, []])
        receptionist = spawn(__MODULE__, :receptionist_process, [waiting_room])

        send(barber, {:set_waiting_room, waiting_room})

        customer_creator(receptionist, 1)
    end

    # recursively creates new customers at random intervals
    def customer_creator(receptionist, id) do
        spawn(__MODULE__, :customer_process, [receptionist, id])
        Process.sleep(:rand.uniform(10000))
        customer_creator(receptionist, id + 1)
    end

    # customer process that interacts with the receptionist to get a haircut
    def customer_process(receptionist, id) do
        IO.puts("Customer #{id} has arrived.")
        send(receptionist, {:new_customer, self(), id})  # Send customer ID with self reference
        receive do
            :shop_full -> IO.puts("Customer #{id} left due to no available seats.")
            :haircut_done -> IO.puts("Customer #{id} got a haircut and is leaving.")
        end
    end

    # receptionist handles the incoming customers and manages the seating queue
    def receptionist_process(waiting_room) do
        receive do
            {:new_customer, customer, id} ->
                IO.puts("Receptionist received new customer #{id}.")
                send(waiting_room, {:seat_customer, customer, id})
                receptionist_process(waiting_room)
        end
    end

    # waiting room manages the queue and interacts with the barber
    def waiting_room_process(barber, max_size, queue) do
        receive do
            {:seat_customer, customer, id} ->
                if length(queue) < max_size do
                    new_queue = queue ++ [{customer, id}]
                    IO.puts("Customer #{id} added to waiting room. Current queue size: #{length(new_queue)}")
                    if length(queue) == 0 do
                        send(barber, {:new_customer, customer, id})
                    end
                    waiting_room_process(barber, max_size, new_queue)
                else
                    IO.puts("No seats available. Customer #{id} turned away.")
                    send(customer, :shop_full)
                    waiting_room_process(barber, max_size, queue)
            end

            {:customer_done} ->
                IO.puts("A customer is done. Removing from the queue.")
                case queue do
                    [{next_customer, next_id} | rest] ->
                        send(barber, {:new_customer, next_customer, next_id})
                        waiting_room_process(barber, max_size, rest)
                    [] ->
                        IO.puts("No more customers in the queue. Barber can rest.")
                        send(barber, {:no_customers})  # Notify the barber that the queue is empty
                        waiting_room_process(barber, max_size, [])
                end

            {:get_next_customer} ->
                case queue do
                    [{next_customer, next_id} | rest] ->
                        IO.puts("Next customer #{next_id} is sent to the barber.")
                        send(barber, {:new_customer, next_customer, next_id})
                        waiting_room_process(barber, max_size, rest)
                    [] ->
                        IO.puts("No customers are in the waiting room.")
                        send(barber, {:no_customers})  # Notify the barber that there are no customers
                        waiting_room_process(barber, max_size, [])
                end
        end
    end


    # barber process handles the customer haircut and managing queue
    def barber_process(waiting_room) do
        receive do
            {:set_waiting_room, room} ->
                barber_process(room)

            {:new_customer, customer, id} ->
                IO.puts("Barber is cutting hair for customer #{id}.")
                Process.sleep(:rand.uniform(3000))
                IO.puts("Haircut finished for customer #{id}.")
                send(customer, :haircut_done)
                if waiting_room != nil do
                    send(waiting_room, {:customer_done})
                end
                barber_process(waiting_room)

            {:no_customers} ->
                IO.puts("Barber is resting, no customers to serve.")
                barber_process(waiting_room)
        end
    end
end

Barbershop.start()

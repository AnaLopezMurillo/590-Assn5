defmodule Barbershop do 
    # Define the consts
    chairs = 6  
    num_waiting = 0
    barber_busy = 0     # 0 for free, 1 for busy

    def start do
        # something here to initialize start # of customers and add to waiting room list, and spawn barber
        IO.puts("Starting the barbershop!")

        # spawn the receptionist here
        receptionist = spawn(fn -> run_receptionist end)    # this is probably wrong idk

        # starts spawning customers in loop
        loop() 
    end

    def barber_sleep() do
        IO.puts("The barber is sleeping...")
    end

    defp cuthair(id) do
        barber_busy = 1
        IO.puts("Barber is cutting hair.")
        :timer.sleep(:rand.uniform(1000))
        barber_busy = 0
    end

    def run_receptionist(id) do
        # check if barber is available
        if barber_busy == 0 do
            IO.puts("Waiting customer with id (put first in line id here) sent to barber!\n")
            # cut hair of the first in the line here
        end

        if num_waiting == 0 do
            IO.puts("Serving customer #{id}.")
            cuthair(id)
        else if chairs > 0 do
            IO.puts("Customer #{id} sent to waiting room.")
            chairs = chairs - 1
        else 
            IO.puts("No chairs available, customer #{id} sent away.")
        end

        IO.puts("")
        :timer.sleep(:rand.uniform(1000))
    end

    defp loop() do
        # idk if this'll necessarily work...my idea is to spawn a pid and send it to receptionist looping
        pid = spawn(__MODULE__, customer: , [[]])
        Process.register(pid, :procName)
        run_receptionist(pid)

        # we might need to add these customers to a list to keep track of queue here

        :timer.sleep(:rand.uniform(5000))
        loop()
    end

    def customer() do
        IO.puts("Customer spawned!\n")
    end

end
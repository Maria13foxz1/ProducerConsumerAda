with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Producer_Consumer_Ada is

   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   Empty_Storage: Counting_Semaphore(0, Default_Ceiling);
   Full_Storage: Counting_Semaphore(10, Default_Ceiling);
   Free_Storage: Counting_Semaphore(3, Default_Ceiling);

   Storage: List;

   task type Producer;
   task type Consumer;

   task body Producer is
   begin
      for I in 1..10 loop
         Full_Storage.Seize;
         Free_Storage.Seize;

         Storage.Append("item " & I'Img);
         Put_Line("Producer add item " & I'Img);

         Empty_Storage.Release;
         Free_Storage.Release;
       end loop;
   end Producer;

   task body Consumer is
   begin
      for I in 1..5 loop
         Empty_Storage.Seize;
         Free_Storage.Seize;

         declare
            Item: String := First_Element(Storage);
         begin
            Put_Line("Consumer get " & Item);
         end;

         Delete_First(Storage);

         Full_Storage.Release;
         Free_Storage.Release;
      end loop;
    end Consumer;

   Cons1: Consumer;
   Prod1: Producer;
   Cons2: Consumer;

begin
   --  Insert code here.
   null;
end Producer_Consumer_Ada;

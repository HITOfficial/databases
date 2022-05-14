namespace TomaszBochnakEFProducts
{
    class Program
    {
        static void Main(string[] args)
        {

            Console.WriteLine("Insert Product Name:");

            string prodName = Console.ReadLine();
            Console.WriteLine("Products list in DB:");
            ProductContext productContext = new ProductContext();
            Product product = new Product { ProductName = prodName};
            productContext.Products.Add(product);
            productContext.SaveChanges();

            var query = from prod in productContext.Products
                        select prod.ProductName;


            foreach (var pName in query)
            {
                Console.WriteLine(pName);
            }
        }

    }
}


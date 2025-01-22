using System;


#if NETFRAMEWORK
using System.Web;
#else
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.IO;
using Microsoft.AspNetCore.Http;
#endif

namespace TesteWebforms
{
#if NETFRAMEWORK
    public static class Program
    {
        [STAThread]
        public static void Main()
        {
            Console.WriteLine("Running under .NET Framework/Mono");
        }
    }
#else
    public class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine($"Running under {Environment.Version}");
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                    webBuilder.UseWebRoot(Directory.GetCurrentDirectory());
                    webBuilder.ConfigureAppConfiguration((hostingContext, config) =>
                    {
                        config.SetBasePath(Directory.GetCurrentDirectory());
                        config.AddJsonFile("appsettings.json", optional: true);
                        config.AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", optional: true);
                        config.AddEnvironmentVariables();
                    });
                });
    }
#endif

#if !NETFRAMEWORK
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddRazorPages();
            services.AddControllersWithViews()
                .AddNewtonsoftJson();

            services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(20);
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
            });
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseStaticFiles();
            app.UseSession();
            app.UseRouting();

            app.Use(async (context, next) =>
            {
                string path = context.Request.Path.Value;
                if (path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
                {
                    string aspxPath = Path.Combine(env.WebRootPath, path.TrimStart('/'));
                    if (File.Exists(aspxPath))
                    {
                        context.Response.ContentType = "text/html";
                        await context.Response.SendFileAsync(aspxPath);
                        return;
                    }
                    context.Response.StatusCode = 404;
                    return;
                }
                await next();
            });

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapRazorPages();
                endpoints.MapControllers();
                endpoints.MapFallbackToFile("Default.aspx");
            });
        }
    }
#endif
}


// #if NETFRAMEWORK
// using System;
// using System.Web;
// #else
// using Microsoft.AspNetCore.Builder;
// using Microsoft.AspNetCore.Hosting;
// using Microsoft.Extensions.DependencyInjection;
// using Microsoft.Extensions.Hosting;
// using System;
// using System.IO;
// using Microsoft.AspNetCore.Http;
// #endif

// namespace TesteWebforms
// {
// #if NETFRAMEWORK
//     public class Program
//     {
//         public static void Main(string[] args)
//         {
//             // No modo Mono/XSP4, não precisamos fazer nada aqui
//             Console.WriteLine("Running under .NET Framework/Mono");
//         }
//     }
// #else
//     public class Program
//     {
//         public static void Main(string[] args)
//         {
//             Console.WriteLine($"Running under {Environment.Version}");
//             CreateHostBuilder(args).Build().Run();
//         }

//         public static IHostBuilder CreateHostBuilder(string[] args) =>
//             Host.CreateDefaultBuilder(args)
//                 .ConfigureWebHostDefaults(webBuilder =>
//                 {
//                     webBuilder.UseStartup<Startup>();
//                     webBuilder.UseWebRoot(Directory.GetCurrentDirectory());
//                     webBuilder.ConfigureAppConfiguration((hostingContext, config) =>
//                     {
//                         config.SetBasePath(Directory.GetCurrentDirectory());
//                         config.AddJsonFile("appsettings.json", optional: true);
//                         config.AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", optional: true);
//                         config.AddEnvironmentVariables();
//                     });
//                 });
//     }

//     public class Startup
//     {
//         public void ConfigureServices(IServiceCollection services)
//         {
//             services.AddRazorPages();
//             services.AddControllersWithViews()
//                     .AddNewtonsoftJson();

//             services.AddSession(options =>
//             {
//                 options.IdleTimeout = TimeSpan.FromMinutes(20);
//                 options.Cookie.HttpOnly = true;
//                 options.Cookie.IsEssential = true;
//             });
//         }

//         public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
//         {
//             if (env.IsDevelopment())
//             {
//                 app.UseDeveloperExceptionPage();
//             }

//             app.UseStaticFiles();
//             app.UseSession();
//             app.UseRouting();

//             // Middleware para processar páginas ASPX
//             app.Use(async (context, next) =>
//             {
//                 string path = context.Request.Path.Value;
//                 if (path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
//                 {
//                     string aspxPath = Path.Combine(env.WebRootPath, path.TrimStart('/'));
//                     if (File.Exists(aspxPath))
//                     {
//                         try
//                         {
//                             // Simula o processamento de uma página ASPX
//                             context.Response.ContentType = "text/html";
//                             string content = File.ReadAllText(aspxPath);

//                             // Processa diretivas
//                             content = ProcessDirectives(content);

//                             // Processa expressões <%= %>
//                             content = ProcessExpressions(content);

//                             await context.Response.WriteAsync(content);
//                             return;
//                         }
//                         catch (Exception ex)
//                         {
//                             await context.Response.WriteAsync($"Error processing ASPX: {ex.Message}");
//                             return;
//                         }
//                     }
//                     context.Response.StatusCode = 404;
//                     return;
//                 }
//                 await next();
//             });

//             app.UseEndpoints(endpoints =>
//             {
//                 endpoints.MapRazorPages();
//                 endpoints.MapControllers();
//                 endpoints.MapFallbackToFile("Default.aspx");
//             });
//         }

//         private string ProcessDirectives(string content)
//         {
//             // Implementação básica do processamento de diretivas
//             // Você pode expandir isso conforme necessário
//             return content;
//         }

//         private string ProcessExpressions(string content)
//         {
//             // Implementação básica do processamento de expressões
//             // Você pode expandir isso conforme necessário
//             return content;
//         }
//     }
// #endif
// }
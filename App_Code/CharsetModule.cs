using System;
using System.Web;

public class CharsetModule : IHttpModule
{
    public void Init(HttpApplication context)
    {
        context.PreRequestHandlerExecute += AddCharset;
    }

    private void AddCharset(object sender, EventArgs e)
    {
        HttpApplication app = (HttpApplication)sender;
        HttpResponse response = app.Response;

        if (response.ContentType.ToLower().StartsWith("text/html"))
        {
            response.Headers.Add("Content-Type", "text/html; charset=utf-8");
        }
    }

    public void Dispose()
    {
    }
}

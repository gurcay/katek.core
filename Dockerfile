# .NET 9 tabanlý ASP.NET çalýþtýrma ortamý
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# .NET SDK içeren yapý ortamý
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["katek.Web.csproj", "./"]
RUN dotnet restore "katek.Web.csproj"
COPY . .
RUN dotnet build "katek.Web.csproj" -c Release -o /app/build

# Yayýnlama aþamasý
FROM build AS publish
RUN dotnet publish "katek.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Son aþama: Çalýþtýrýlabilir ortam
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Veritabaný ve medya dosyalarýný ekleyelim
COPY wwwroot/media /app/wwwroot/media
COPY umbraco/Data/katekDb.sqlite.db /app/umbraco/Data/katekDb.sqlite.db

ENTRYPOINT ["dotnet", "katek.Web.dll"]
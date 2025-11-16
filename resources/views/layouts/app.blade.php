<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title','Maintenance RS')</title>
  <link href="/css/app.css" rel="stylesheet">
</head>
<body class="bg-gray-50 font-sans">
  <div class="flex">
    <aside class="w-64 bg-white h-screen p-4 border-r">
      <div class="font-bold text-lg">RS Maintenance</div>
      <nav class="mt-6 space-y-2">
        <a href="/dashboard" class="block p-2 rounded hover:bg-gray-100">Dashboard</a>
        <a href="/assets" class="block p-2 rounded hover:bg-gray-100">Assets</a>
        <a href="#" class="block p-2 rounded hover:bg-gray-100">PM</a>
        <a href="#" class="block p-2 rounded hover:bg-gray-100">CM</a>
      </nav>
    </aside>
    <main class="flex-1 p-6">
      <header class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-semibold">@yield('page_title','Dashboard')</h1>
        <div class="flex items-center gap-4">
          <input class="border rounded p-2" placeholder="Search..." />
          <img src="/img/avatar.jpg" class="w-8 h-8 rounded-full" alt="avatar">
        </div>
      </header>

      @yield('content')
    </main>
  </div>
</body>
</html>

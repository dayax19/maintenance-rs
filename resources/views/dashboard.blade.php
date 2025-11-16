@extends('layouts.app')
@section('page_title','Dashboard')
@section('content')
<div class="grid grid-cols-4 gap-4">
  <div class="p-4 bg-white rounded shadow">Total Assets<br><span class="text-2xl font-bold">123</span></div>
  <div class="p-4 bg-white rounded shadow">PM Due<br><span class="text-2xl font-bold text-yellow-600">12</span></div>
  <div class="p-4 bg-white rounded shadow">CM Active<br><span class="text-2xl font-bold text-red-600">5</span></div>
  <div class="p-4 bg-white rounded shadow">Technicians<br><span class="text-2xl font-bold">24</span></div>
</div>

<div class="mt-6 bg-white rounded shadow p-4">
  <h3 class="font-semibold mb-4">Latest Tickets</h3>
  <table class="w-full text-left">
    <thead>
      <tr><th>Code</th><th>Asset</th><th>Type</th><th>Assigned</th><th>Status</th></tr>
    </thead>
    <tbody>
      <tr><td>CM-00123</td><td>ECG Machine - ICU</td><td>Corrective</td><td>Rizal</td><td><span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded">On Progress</span></td></tr>
    </tbody>
  </table>
</div>
@endsection

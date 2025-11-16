<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class MaintenancePM extends Model {
    use HasFactory;
    protected $table = 'maintenance_pm';
    protected $casts = ['checklist'=>'array'];
    protected $fillable = ['asset_id','ticket_code','scheduled_date','due_date','assigned_technician','status','checklist','notes','completed_at'];
    public function asset(){ return $this->belongsTo(Asset::class,'asset_id'); }
    public function technician(){ return $this->belongsTo(User::class,'assigned_technician'); }
}

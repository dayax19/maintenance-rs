<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class MaintenanceCM extends Model {
    use HasFactory;
    protected $table = 'maintenance_cm';
    protected $casts = ['spareparts_used'=>'array'];
    protected $fillable = ['asset_id','ticket_code','reported_by','reported_at','priority','assigned_technician','status','description','spareparts_used','cost_total','resolved_at'];
    public function asset(){ return $this->belongsTo(Asset::class,'asset_id'); }
    public function reporter(){ return $this->belongsTo(User::class,'reported_by'); }
    public function technician(){ return $this->belongsTo(User::class,'assigned_technician'); }
}

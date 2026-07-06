<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ScanHistory extends Model
{
    protected $fillable = [
        'session_id',
        'module',
        'input_text',
        'risk_level',
        'matched_pattern',
        'explanation',
    ];
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ScamPattern extends Model
{
    protected $fillable = [
        'external_id',
        'category',
        'label',
        'risk_level',
        'text_bn',
        'location_label',
        'red_flags_bn',
        'pattern_basis',
        'is_synthetic',
        'is_community_report',
    ];

    protected $casts = [
        'is_synthetic' => 'boolean',
        'is_community_report' => 'boolean',
    ];
}

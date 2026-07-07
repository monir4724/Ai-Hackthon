<?php

$frontendUrl = env('FRONTEND_URL');
$allowedOrigins = array_values(array_filter([
    $frontendUrl,
    'http://localhost:5173',
    'http://127.0.0.1:5173',
]));

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => $allowedOrigins !== [] ? $allowedOrigins : ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];

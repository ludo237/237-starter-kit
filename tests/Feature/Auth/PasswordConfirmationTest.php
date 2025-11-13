<?php

declare(strict_types=1);

use Database\Factories\UserFactory;
use Inertia\Testing\AssertableInertia as Assert;

uses(Illuminate\Foundation\Testing\RefreshDatabase::class);

test('confirm password screen can be rendered', function (): void {
    $user = UserFactory::new()->create();

    $response = $this->actingAs($user)->get(route('password.confirm'));

    $response->assertStatus(200);

    $response->assertInertia(fn (Assert $page): Assert => $page
        ->component('auth/confirm-password')
    );
});

test('password confirmation requires authentication', function (): void {
    $response = $this->get(route('password.confirm'));

    $response->assertRedirect(route('login'));
});

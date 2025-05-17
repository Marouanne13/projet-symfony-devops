<?php

namespace App\Controller;

use Prometheus\CollectorRegistry;
use Prometheus\RenderTextFormat;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class MetricsController extends AbstractController
{
    #[Route('/metrics', name: 'metrics')]
    public function metrics(): Response
    {
        $registry = CollectorRegistry::getDefault();
        $renderer = new RenderTextFormat();
        $metrics = $renderer->render($registry->getMetricFamilySamples());

        return new Response($metrics, 200, [
            'Content-Type' => RenderTextFormat::MIME_TYPE
        ]);
    }
}
